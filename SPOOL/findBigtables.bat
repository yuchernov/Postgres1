@mode con cp select=1251 > nul

set "delimeter1="
set /p=<nul > C:\Users\%username%\Desktop\SPOOL\CSV\tmp_bigTables.txt

for /F "tokens=1-2 delims=." %%i in (C:\Users\%username%\Desktop\SPOOL\tables.txt) do (

echo prompt Start the unloading process... > TMP\findBigTables.sql
echo set colsep '' >> TMP\findBigTables.sql
echo set echo off >> TMP\findBigTables.sql
echo set feedback off >> TMP\findBigTables.sql
echo set linesize 15000 >> TMP\findBigTables.sql
echo set serveroutput on >> TMP\findBigTables.sql
echo set pagesize 0 >> TMP\findBigTables.sql
echo set sqlprompt '' >> TMP\findBigTables.sql
echo set trimspool on >> TMP\findBigTables.sql
echo set headsep off >> TMP\findBigTables.sql
echo set long 200000 >> TMP\findBigTables.sql
echo set longchunksize 200000 >> TMP\findBigTables.sql
echo set pages 0 >> TMP\findBigTables.sql
echo set termout off >> TMP\findBigTables.sql
echo set wrap off  >> TMP\findBigTables.sql
echo alter session set nls_date_format="dd.mm.yyyy hh24:mi:ss"; >> TMP\findBigTables.sql
echo alter session set nls_timestamp_format="dd.mm.yyyy hh24:mi:ss"; >> TMP\findBigTables.sql

echo SPOOL C:\Users\%username%\Desktop\SPOOL\CSV\tmp_bigTables.txt append; >> TMP\findBigTables.sql

echo DECLARE >> TMP\findBigTables.sql
echo lv_rowscn NUMBER^(30^); >> TMP\findBigTables.sql
echo BEGIN >> TMP\findBigTables.sql
echo 	FOR rec IN ^(select owner, owner^|^|'.'^|^|object_name^|^|'.'^|^|^(SELECT to_char^(SUM^(Bytes ^/ 1024 ^/ 1024 ^/ 1024 ^) OVER ^(PARTITION BY Segment_Name^),'FM999'^) FROM DBA_Extents WHERE  Segment_Name = object_name FETCH NEXT 1 ROWS only^) AS AL, object_name from dba_objects WHERE owner = '%%i' AND object_type = 'TABLE' AND object_name = '%%j'^) LOOP >> TMP\findBigTables.sql
echo 	EXECUTE IMMEDIATE 'SELECT max^(ora_rowscn^) FROM '^|^|rec.owner^|^|'.'^|^|rec.object_name INTO lv_rowscn; >> TMP\findBigTables.sql
echo 	dbms_output.put_line^(rec.al^|^|'.'^|^|lv_rowscn^); >> TMP\findBigTables.sql
echo 	END LOOP; >> TMP\findBigTables.sql
echo END; >> TMP\findBigTables.sql
echo / >> TMP\findBigTables.sql
echo spool off; >> TMP\findBigTables.sql
echo prompt Done >> TMP\findBigTables.sql
echo exit; >> TMP\findBigTables.sql
SQLPLUS OT/wertuaL777@testdb @TMP\findBigTables.sql
)

copy /v C:\Users\%username%\Desktop\SPOOL\CSV\tmp_bigTables.txt C:\Users\%username%\Desktop\SPOOL\APPEND\check_scn_new.txt

set /p=<nul > C:\Users\%username%\Desktop\SPOOL\tables_big.txt

for /F "tokens=1-3 delims=." %%i in (C:\Users\%username%\Desktop\SPOOL\CSV\tmp_bigTables.txt) do (
if %%k GEQ 1 (echo %%j>> C:\Users\%username%\Desktop\SPOOL\tables_big.txt)
)

