@mode con cp select=1251 > nul

call "init_config.bat"

set "delimeter1="
set "delimeter2="

echo prompt Start the unloading process... > TMP\importToCsv.sql
echo set colsep '`' >> TMP\importToCsv.sql
echo set echo off >> TMP\importToCsv.sql
echo set feedback off >> TMP\importToCsv.sql
echo set linesize 15000 >> TMP\importToCsv.sql
echo set pagesize 0 >> TMP\importToCsv.sql
echo set sqlprompt '' >> TMP\importToCsv.sql
echo set trimspool on >> TMP\importToCsv.sql
echo set headsep off >> TMP\importToCsv.sql
echo set termout off  >> TMP\importToCsv.sql
echo set wrap off  >> TMP\importToCsv.sql
echo set define off >> TMP\importToCsv.sql
echo set long 200000 >> TMP\importToCsv.sql
echo set longchunksize 200000 >> TMP\importToCsv.sql
echo set pages 0 >> TMP\importToCsv.sql


echo SPOOL C:\Users\%username%\Desktop\SPOOL\CSV\tmp_csv.txt; >> TMP\importToCsv.sql
::echo select LISTAGG(column_name, '^^^|^^^|''@''^^^|^^^|') WITHIN GROUP (order by column_id) as list from dba_tab_columns t where table_name = '%2' and owner = '%1' group by table_name; >> TMP\importToCsv.sql

::old 03.08.2022
::echo select LISTAGG^(CASE WHEN DATA_TYPE not in ^('CLOB', 'VARCHAR2', 'NVARCHAR2'^) THEN column_name ELSE 'regexp_replace^(regexp_replace^(regexp_replace^('^|^|column_name^|^|',''^(  *^)'','' ''^),chr^(10^),'' ''^),chr^(13^),'' ''^)' END, '^^^|^^^|''%delimeter1%''^^^|^^^|'^) WITHIN GROUP ^(order by column_id^) as list from dba_tab_columns t where table_name = '%2' and owner = '%1' group by table_name; >> TMP\importToCsv.sql

echo SELECT REPLACE^(REPLACE^(regexp_substr^(rtrim^(xmlagg^(XMLELEMENT^(e,text,'#'^).EXTRACT^('//text^(^)'^)^).GetClobVal^(^),','^),'^(.*^)#[^#]*$',1,1,'i',1^),'#','^|^|''%delimeter1%''^|^|'^),'^&apos;',''''^) very_long_text FROM ^(SELECT ^(CASE WHEN DATA_TYPE not in ^('CLOB', 'VARCHAR2', 'NVARCHAR2'^) THEN 'rec(i).'^|^|column_name ELSE 'regexp_replace^(regexp_replace^(regexp_replace^('^|^|'rec(i).'^|^|column_name^|^|',''^(  *^)'','' ''^),chr^(10^),'' ''^),chr^(13^),'' ''^)' END^) AS text from dba_tab_columns t where table_name = '%2' and owner = '%1' order by column_id^); >> TMP\importToCsv.sql


::echo select LISTAGG(CASE WHEN DATA_TYPE not in ('CLOB', 'VARCHAR2') THEN column_name ELSE 'regexp_replace(regexp_replace(regexp_replace('^|^|column_name^|^|',''(  *)'','' ''),chr(10),'' ''),chr(13),'' '')' END, '^^^|^^^|''!delimeter!''^^^|^^^|') WITHIN GROUP (order by column_id) as list from dba_tab_columns t where table_name = '%2' and owner = '%1' group by table_name; >> TMP\importToCsv.sql


::echo select LISTAGG(CASE WHEN DATA_TYPE not in ('CLOB', 'VARCHAR2') THEN column_name ELSE 'regexp_replace(regexp_replace(regexp_replace('^|^|column_name^|^|',''(  *)'','' ''),chr(10),'' ''),chr(13),'' '')' END, '^^^|^^^|''%delimeter%''^^^|^^^|') WITHIN GROUP (order by column_id) as list from dba_tab_columns t where table_name = '%2' and owner = '%1' group by table_name; >> TMP\importToCsv.sql

echo spool off; >> TMP\importToCsv.sql

:: FOR LONG TABLES
echo SPOOL C:\Users\%username%\Desktop\SPOOL\CSV\tmp_csv_2.txt; >> TMP\importToCsv.sql
echo SELECT REPLACE^(REPLACE^(regexp_substr^(rtrim^(xmlagg^(XMLELEMENT^(e,text,'#'^).EXTRACT^('//text^(^)'^)^).GetClobVal^(^),','^),'^(.*^)#[^#]*$',1,1,'i',1^),'#','^|^|''%delimeter1%''^|^|'^),'^&apos;',''''^) very_long_text FROM ^(SELECT ^(CASE WHEN DATA_TYPE not in ^('CLOB', 'VARCHAR2', 'NVARCHAR2'^) THEN column_name ELSE 'regexp_replace^(regexp_replace^(regexp_replace^('^|^|column_name^|^|',''^(  *^)'','' ''^),chr^(10^),'' ''^),chr^(13^),'' ''^)' END^) AS text from dba_tab_columns t where table_name = '%2' and owner = '%1' order by column_id^); >> TMP\importToCsv.sql
echo spool off; >> TMP\importToCsv.sql


echo prompt Done >> TMP\importToCsv.sql
echo exit; >> TMP\importToCsv.sql

SQLPLUS OT/wertuaL777@testdb @TMP\importToCsv.sql


Set file=C:\Users\%username%\Desktop\SPOOL\CSV\tmp_csv.txt
For /F "usebackq tokens=* delims=" %%q In ("%file%") Do Set var=%%q


Set file_2=C:\Users\%username%\Desktop\SPOOL\CSV\tmp_csv_2.txt
For /F "usebackq tokens=* delims=" %%q In ("%file_2%") Do Set var_2=%%q


:: echo %var% > C:\Users\%username%\Desktop\SPOOL\CSV\%2.txt

echo prompt Start the unloading process... > TMP\%2.sql
echo set colsep '' >> TMP\%2.sql
echo set echo off >> TMP\%2.sql
echo set feedback off >> TMP\%2.sql
echo set linesize 15000 >> TMP\%2.sql
echo set pagesize 0 >> TMP\%2.sql
echo set sqlprompt '' >> TMP\%2.sql
echo set trimspool on >> TMP\%2.sql
echo set headsep off >> TMP\%2.sql
echo set long 200000 >> TMP\%2.sql
echo set longchunksize 200000 >> TMP\%2.sql
echo set pages 0 >> TMP\%2.sql
echo set termout off  >> TMP\%2.sql
echo set wrap off  >> TMP\%2.sql
echo set serveroutput on >> TMP\%2.sql

::echo alter session set nls_date_format="dd.mm.yyyy hh24:mi:ss"; >> TMP\%2.sql
::echo alter session set nls_timestamp_format="dd.mm.yyyy hh24:mi:ss"; >> TMP\%2.sql
echo alter session set nls_date_format="yyyy-mm-dd hh24:mi:ss"; >> TMP\%2.sql
echo alter session set nls_timestamp_format="yyyy-mm-dd hh24:mi:ss"; >> TMP\%2.sql
:: local C:\

if %~6 GEQ 0 (echo SPOOL C:\Users\Yury\Desktop\SPOOL\CSV\SPLIT_FILE\%2_%~5.csv; >> TMP\%2.sql
for /F "tokens=1 delims=^" %%a in ("%var%") do (set nvar=%%a)
) else (echo SPOOL C:\Users\Yury\Desktop\SPOOL\CSV\%2.csv; >> TMP\%2.sql 
set nvar=)


for /F "delims=" %%b in ('type C:\Users\%username%\Desktop\SPOOL\tables_long.txt ^| findstr /x "%2" ^| find /c /v ""') do (
if %%b==1 (

<nul set /p str="select %var_2% from %1.%2 %~3 %nvar% %~4 %~5;">>TMP\%2.sql
) else (echo DECLARE  >> TMP\%2.sql
echo TYPE type_record IS TABLE OF %1.%2%%ROWTYPE; >> TMP\%2.sql
echo rec type_record; >> TMP\%2.sql
echo CURSOR main_cur_for_import IS select * from %1.%2 %~3 %nvar% %~4 %~5; >> TMP\%2.sql
echo BEGIN >> TMP\%2.sql
echo OPEN main_cur_for_import; >> TMP\%2.sql
echo LOOP >> TMP\%2.sql
echo FETCH main_cur_for_import BULK COLLECT >> TMP\%2.sql
echo INTO rec LIMIT 1000; >> TMP\%2.sql
echo EXIT WHEN rec.count = 0; >> TMP\%2.sql
echo for i IN 1..rec.count LOOP >> TMP\%2.sql
<nul set /p str="dbms_output.put_line(%var%);" >> TMP\%2.sql
echo END LOOP; >> TMP\%2.sql
echo END LOOP; >> TMP\%2.sql
echo CLOSE main_cur_for_import; >> TMP\%2.sql
echo END; >> TMP\%2.sql
echo / >> TMP\%2.sql
)
)
echo. >> TMP\%2.sql
echo spool off; >> TMP\%2.sql
echo prompt Done >> TMP\%2.sql
echo exit; >> TMP\%2.sql

SQLPLUS OT/wertuaL777@testdb @TMP\%2.sql