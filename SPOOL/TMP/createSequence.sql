prompt Start the unloading process... 
set colsep ';' 
set echo off 
set feedback off 
set linesize 1000 
set pagesize 0 
set sqlprompt '' 
set trimspool on 
set headsep off 
set serveroutput on 
SPOOL C:\Users\Yury\Desktop\SPOOL\TMP\createSequence.txt; 
DECLARE lv_schema_name varchar(100) := 'OT'; 
BEGIN 
	FOR rec IN (select * from DBA_SEQUENCES WHERE sequence_owner = 'OT') LOOP 
	IF rec.max_value like '999999999999999999%' 
		THEN rec.max_value := 999999999999999999 ; 
	END IF; 
	rec.LAST_NUMBER := rec.LAST_NUMBER+1; 
if rec.CACHE_SIZE = 0 then rec.CACHE_SIZE := 1; 
end if; 
	dbms_output.put_line('create sequence if not exists '||rec.sequence_owner||'.'||rec.SEQUENCE_NAME||' increment by '||rec.INCREMENT_BY|| 
	' minvalue '||rec.min_value||' maxvalue '||rec.MAX_VALUE||' start with '||rec.LAST_NUMBER||' cache '||rec.CACHE_SIZE||';' 
	); 
	dbms_output.put_line('alter sequence if exists '||rec.sequence_owner||'.'||rec.SEQUENCE_NAME||' set schema '||lv_schema_name||';'); 
	dbms_output.put_line('alter sequence if exists '||rec.sequence_owner||'.'||rec.SEQUENCE_NAME||' owner to '||lv_schema_name||';'); 
	dbms_output.put_line('alter sequence if exists '||rec.sequence_owner||'.'||rec.SEQUENCE_NAME||' restart '||rec.LAST_NUMBER||';'); 
	END LOOP; 
END; 
/ 
spool off; 
prompt Done 
exit; 
