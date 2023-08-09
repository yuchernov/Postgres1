prompt Start the unloading process... 
set colsep '`' 
set echo off 
set feedback off 
set linesize 15000 
set pagesize 0 
set sqlprompt '' 
set trimspool on 
set headsep off 
set termout off  
set wrap off  
set define off 
set long 200000 
set longchunksize 200000 
set pages 0 
SPOOL C:\Users\Yury\Desktop\SPOOL\CSV\tmp_csv.txt; 
SELECT REPLACE(REPLACE(regexp_substr(rtrim(xmlagg(XMLELEMENT(e,text,'#').EXTRACT('//text()')).GetClobVal(),','),'(.*)#[#]*$',1,1,'i',1),'#','||''''||'),'&apos;','''') very_long_text FROM (SELECT (CASE WHEN DATA_TYPE not in ('CLOB', 'VARCHAR2', 'NVARCHAR2') THEN 'rec(i).'||column_name ELSE 'regexp_replace(regexp_replace(regexp_replace('||'rec(i).'||column_name||',''(  *)'','' ''),chr(10),'' ''),chr(13),'' '')' END) AS text from dba_tab_columns t where table_name = 'WAREHOUSES' and owner = 'OT' order by column_id); 
spool off; 
SPOOL C:\Users\Yury\Desktop\SPOOL\CSV\tmp_csv_2.txt; 
SELECT REPLACE(REPLACE(regexp_substr(rtrim(xmlagg(XMLELEMENT(e,text,'#').EXTRACT('//text()')).GetClobVal(),','),'(.*)#[#]*$',1,1,'i',1),'#','||''''||'),'&apos;','''') very_long_text FROM (SELECT (CASE WHEN DATA_TYPE not in ('CLOB', 'VARCHAR2', 'NVARCHAR2') THEN column_name ELSE 'regexp_replace(regexp_replace(regexp_replace('||column_name||',''(  *)'','' ''),chr(10),'' ''),chr(13),'' '')' END) AS text from dba_tab_columns t where table_name = 'WAREHOUSES' and owner = 'OT' order by column_id); 
spool off; 
prompt Done 
exit; 
