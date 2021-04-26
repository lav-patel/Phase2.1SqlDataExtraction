set echo on;
WHENEVER SQLERROR CONTINUE;
drop table PATIENTCLINICALCOURSE_bkp;
drop table cc_readmit;
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
--    where patient_num=100041
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
    --dbms_output.put_line(r.diff);
    for r2 in 2..r.diff
    LOOP
        --dbms_output.put_line('--'||r2);
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