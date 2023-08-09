@mode con cp select=1251 > nul



set "delimeter1="
set /p=<nul > C:\Users\%username%\Desktop\SPOOL\CSV\tmp_LongTables.txt
set /p schema_name=<C:\Users\%username%\Desktop\SPOOL\tables.txt
echo %schema_name% > C:\Users\%username%\Desktop\SPOOL\TMP\schema_name.txt
for /F "tokens=1-2 delims=." %%i in (C:\Users\%username%\Desktop\SPOOL\TMP\schema_name.txt) do (

echo prompt Start the unloading process... > TMP\findLongTables.sql
echo set colsep '' >> TMP\findLongTables.sql
echo set echo off >> TMP\findLongTables.sql
echo set feedback off >> TMP\findLongTables.sql
echo set linesize 15000 >> TMP\findLongTables.sql
echo set serveroutput on >> TMP\findLongTables.sql
echo set pagesize 0 >> TMP\findLongTables.sql
echo set sqlprompt '' >> TMP\findLongTables.sql
echo set trimspool on >> TMP\findLongTables.sql
echo set headsep off >> TMP\findLongTables.sql
echo set long 200000 >> TMP\findLongTables.sql
echo set longchunksize 200000 >> TMP\findLongTables.sql
echo set pages 0 >> TMP\findLongTables.sql
echo set termout off >> TMP\findLongTables.sql
echo set wrap off  >> TMP\findLongTables.sql
echo alter session set nls_date_format="dd.mm.yyyy hh24:mi:ss"; >> TMP\findLongTables.sql
echo alter session set nls_timestamp_format="dd.mm.yyyy hh24:mi:ss"; >> TMP\findLongTables.sql

echo SPOOL C:\Users\%username%\Desktop\SPOOL\CSV\tmp_LongTables.txt append; >> TMP\findLongTables.sql

echo DECLARE  >> TMP\findLongTables.sql
echo lv_cnt pls_integer; >> TMP\findLongTables.sql
echo BEGIN  >> TMP\findLongTables.sql
echo 	FOR rec IN ^(SELECT OWNER^|^|'.'^|^|OBJECT_NAME AS TABLE_NAME FROM dba_objects t WHERE owner = '%%i'  >> TMP\findLongTables.sql
echo 	AND object_type = 'TABLE' >> TMP\findLongTables.sql
echo 	^) LOOP  >> TMP\findLongTables.sql
echo 	BEGIN  >> TMP\findLongTables.sql
echo 		EXECUTE IMMEDIATE 'select count^(1^) from '^|^|rec.TABLE_NAME INTO lv_cnt; >> TMP\findLongTables.sql
echo 		IF lv_cnt ^> 500000 THEN >> TMP\findLongTables.sql
echo 			dbms_output.put_line^(rec.TABLE_NAME^|^|'.'^|^|lv_cnt^); >> TMP\findLongTables.sql
echo 		END IF; >> TMP\findLongTables.sql
echo 	EXCEPTION WHEN OTHERS THEN >> TMP\findLongTables.sql
echo 		dbms_output.put_line^(rec.TABLE_NAME^|^|'.'^|^|'ERR'^); >> TMP\findLongTables.sql
echo 	END; >> TMP\findLongTables.sql
echo 	END LOOP; >> TMP\findLongTables.sql
echo END; >> TMP\findLongTables.sql
echo / >> TMP\findLongTables.sql
echo spool off; >> TMP\findLongTables.sql
echo prompt Done >> TMP\findLongTables.sql
echo exit; >> TMP\findLongTables.sql

SQLPLUS OT/wertuaL777@testdb @TMP\findLongTables.sql
)

set /p=<nul > C:\Users\%username%\Desktop\SPOOL\tables_long.txt

for /F "tokens=1-3 delims=." %%i in (C:\Users\%username%\Desktop\SPOOL\CSV\tmp_LongTables.txt) do (
if %%k GEQ 500000 (echo %%j>> C:\Users\%username%\Desktop\SPOOL\tables_long.txt)
)

