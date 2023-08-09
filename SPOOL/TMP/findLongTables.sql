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
SPOOL C:\Users\Yury\Desktop\SPOOL\CSV\tmp_LongTables.txt append; 
DECLARE  
lv_cnt pls_integer; 
BEGIN  
	FOR rec IN (SELECT OWNER||'.'||OBJECT_NAME AS TABLE_NAME FROM dba_objects t WHERE owner = 'OT'  
	AND object_type = 'TABLE' 
	) LOOP  
	BEGIN  
		EXECUTE IMMEDIATE 'select count(1) from '||rec.TABLE_NAME INTO lv_cnt; 
		IF lv_cnt > 500000 THEN 
			dbms_output.put_line(rec.TABLE_NAME||'.'||lv_cnt); 
		END IF; 
	EXCEPTION WHEN OTHERS THEN 
		dbms_output.put_line(rec.TABLE_NAME||'.'||'ERR'); 
	END; 
	END LOOP; 
END; 
/ 
spool off; 
prompt Done 
exit; 
