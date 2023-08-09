prompt Start the unloading process... 
set colsep '' 
set echo off 
set feedback off 
set linesize 15000 
set serveroutput on 
set pagesize 0 
set sqlprompt '' 
set trimspool on 
set headsep off 
set long 200000 
set longchunksize 200000 
set pages 0 
set termout off 
set wrap off  
alter session set nls_date_format="dd.mm.yyyy hh24:mi:ss"; 
alter session set nls_timestamp_format="dd.mm.yyyy hh24:mi:ss"; 
SPOOL C:\Users\Yury\Desktop\SPOOL\CSV\tmp_bigTables.txt append; 
DECLARE 
lv_rowscn NUMBER(30); 
BEGIN 
	FOR rec IN (select owner, owner||'.'||object_name||'.'||(SELECT to_char(SUM(Bytes / 1024 / 1024 / 1024 ) OVER (PARTITION BY Segment_Name),'FM999') FROM DBA_Extents WHERE  Segment_Name = object_name FETCH NEXT 1 ROWS only) AS AL, object_name from dba_objects WHERE owner = 'OT' AND object_type = 'TABLE' AND object_name = 'WAREHOUSES') LOOP 
	EXECUTE IMMEDIATE 'SELECT max(ora_rowscn) FROM '||rec.owner||'.'||rec.object_name INTO lv_rowscn; 
	dbms_output.put_line(rec.al||'.'||lv_rowscn); 
	END LOOP; 
END; 
/ 
spool off; 
prompt Done 
exit; 
