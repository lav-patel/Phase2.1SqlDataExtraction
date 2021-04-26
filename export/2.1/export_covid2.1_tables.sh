set -x

sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTCLINICALCOURSE.sql
sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTMAPPING.sql
sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTOBSERVATIONS.sql
sqlplus $USER_NAME/$USER_PASSWORD@$ORACLE_SID @P2PATIENTSUMMARY.sql


sed -i 1i"SITEID ,PATIENT_NUM ,DAYS_SINCE_ADMISSION ,CALENDAR_DATE ,IN_HOSPITAL ,SEVERE ,DECEASED" LocalPatientClinicalCourse.csv
sed -i 1i"SITEID ,PATIENT_NUM ,STUDY_NUM" LocalPatientMapping.csv
sed -i 1i"SITEID ,PATIENT_NUM ,DAYS_SINCE_ADMISSION , CONCEPT_TYPE ,CONCEPT_CODE ,VALUE" LocalPatientObservations.csv
sed -i 1i"SITEID ,PATIENT_NUM ,ADMISSION_DATE ,DAYS_SINCE_ADMISSION ,LAST_DISCHARGE_DATE ,STILL_IN_HOSPITAL ,SEVERE_DATE ,SEVERE ,DEATH_DATE ,DECEASED ,SEX ,AGE_GROUP ,RACE ,RACE_COLLECTED" \
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
