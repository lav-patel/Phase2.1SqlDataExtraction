set echo on;
WHENEVER SQLERROR CONTINUE;
drop table PATIENTCLINICALCOURSE_bkp;
drop table cc_readmit;
drop table days_before_deceased;
WHENEVER SQLERROR EXIT SQL.SQLCODE

create table PATIENTCLINICALCOURSE_bkp
as
select * from PATIENTCLINICALCOURSE;

create table cc_readmit as
with cc_diff
as
(
    select 
      cc.*
     ,days_since_admission - LAG(days_since_admission,1,0) OVER (partition by patient_num ORDER BY days_since_admission) diff
    from PATIENTCLINICALCOURSE cc
)
,cc_readmit as
(
    select * 
    from cc_diff
    where diff not in (0,1)
    order by patient_num,days_since_admission
)
select * from cc_readmit
;

set serveroutput on size 1000000;
BEGIN
  FOR r IN (select * from cc_readmit)
  LOOP
    for r2 in 2..r.diff
    LOOP
        -- 0 for outside hospital
        insert into PATIENTCLINICALCOURSE (siteid,patient_num,days_since_admission, calendar_date, in_hospital, severe, deceased)
        values (r.siteid,r.patient_num,r.days_since_admission-r2+1, r.calendar_date-r2+1, 0, r.severe, r.deceased);
    END LOOP;
    
  END LOOP;
END;
/

-- test changes
with cc_diff
as
(
    select 
      cc.*
     ,days_since_admission - LAG(days_since_admission,1,0) OVER (partition by patient_num ORDER BY days_since_admission) diff
    from PATIENTCLINICALCOURSE cc
)
,cc_readmit as
(
    select * 
    from cc_diff
    where diff not in (0,1)
    order by patient_num,days_since_admission
)
select count(*) from cc_readmit
;

commit;

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- the death and severe flags are on visit level, not patient level
-- Death flag
--------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE days_before_deceased as
WITH PATIENTCLINICALCOURSE_deceased AS
(
SELECT * 
FROM PATIENTCLINICALCOURSE
WHERE deceased=1 
)
,last_day AS
(
SELECT PATIENT_NUM , max(DAYS_SINCE_ADMISSION) last_day_at_hospital
FROM PATIENTCLINICALCOURSE_deceased
GROUP BY PATIENT_NUM
)
,days_before_deceased
AS
(
SELECT 
d.PATIENT_NUM,
d.DAYS_SINCE_ADMISSION,
0 DECEASED 
FROM PATIENTCLINICALCOURSE_deceased d
JOIN last_day l
	ON d.patient_num = l.patient_num
	 AND d.DAYS_SINCE_ADMISSION <> l.last_day_at_hospital
ORDER BY d.PATIENT_NUM, d.DAYS_SINCE_ADMISSION
)
SELECT * FROM days_before_deceased
;
UPDATE PATIENTCLINICALCOURSE cc
SET cc.DECEASED = 0
WHERE cc.PATIENT_NUM||cc.DAYS_SINCE_ADMISSION IN (SELECT PATIENT_NUM||DAYS_SINCE_ADMISSION FROM days_before_deceased)
;
-- testing 
SELECT 
	CASE WHEN count(DISTINCT PATIENT_NUM)= sum(DECEASED)
		 THEN 1 -- testing pass
		 ELSE 1/0 -- testing failed
	END 
FROM PATIENTCLINICALCOURSE
WHERE DECEASED =1;
COMMIT;
