set -x

sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTCLINICALCOURSE.sql
sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTMAPPING.sql
sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTOBSERVATIONS.sql
sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTSUMMARY.sql


sed -i 1i"siteid ,patient_num ,days_since_admission ,calendar_date ,in_hospital ,severe ,deceased" LocalPatientClinicalCourse.csv
sed -i 1i"siteid ,patient_num ,study_num" LocalPatientMapping.csv
sed -i 1i"siteid ,patient_num ,days_since_admission , concept_type ,concept_code ,value" LocalPatientObservations.csv
sed -i 1i"siteid ,patient_num ,admission_date ,days_since_admission ,last_discharge_date ,still_in_hospital ,severe_date ,severe ,death_date ,deceased ,sex ,age_group ,race ,race_collected" \
    LocalPatientSummary.csv

exit 0

# code to generate sql for export and header
select table_name ,
'select '|| listagg(column_name,' || '','' || ') within group( order by column_id ) || ' from ' || table_name || ';' sql

,listagg(column_name,',') within group( order by column_id ) header
from all_tab_cols
where OWNER ='LPATEL'
    and table_name like 'P2P%'
group by table_name
order by table_name;
