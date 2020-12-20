ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SET TRIMSPOOL ON; -- otherwise every line in the spoolfile is filled up with blanks until the linesize is reached.
SET TRIMOUT ON; -- otherwise every line in the output is filled up with blanks until the linesize is reached.
SET WRAP OFF; -- Truncates the line if its is longer then LINESIZE. This should not happen if linesize is large enough.
SET TERMOUT OFF; -- suppresses the printing of the results to the output. The lines are still written to the spool file. This may accelerate the exectution time of a statement a lot.
set linesize 32000
set pagesize 0  -- No header rows
set feedback off
set markup csv on
spool LocalPatientSummary.csv
set colsep ','
select SITEID || ',' || PATIENT_NUM || ',' || ADMISSION_DATE || ',' || DAYS_SINCE_ADMISSION || ',' || LAST_DISCHARGE_DATE || ',' || STILL_IN_HOSPITAL || ',' || SEVERE_DATE || ',' || SEVERE || ',' || DEATH_DATE || ',' || DECEASED || ',' || SEX || ',' || AGE_GROUP || ',' || RACE || ',' || RACE_COLLECTED from P2PATIENTSUMMARY;
spool off;
exit;
