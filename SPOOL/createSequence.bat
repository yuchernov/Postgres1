:: create sequence

cd C:\Users\%username%\Desktop\SPOOL
echo prompt Start the unloading process... > TMP\createSequence.sql
echo set colsep ';' >> TMP\createSequence.sql
echo set echo off >> TMP\createSequence.sql
echo set feedback off >> TMP\createSequence.sql
echo set linesize 1000 >> TMP\createSequence.sql
echo set pagesize 0 >> TMP\createSequence.sql
echo set sqlprompt '' >> TMP\createSequence.sql
echo set trimspool on >> TMP\createSequence.sql
echo set headsep off >> TMP\createSequence.sql
echo set serveroutput on >> TMP\createSequence.sql

echo SPOOL C:\Users\%username%\Desktop\SPOOL\TMP\createSequence.txt; >> TMP\createSequence.sql

echo DECLARE lv_schema_name varchar(100) := 'OT'; >> TMP\createSequence.sql
echo BEGIN >> TMP\createSequence.sql
echo 	FOR rec IN (select * from DBA_SEQUENCES WHERE sequence_owner = 'OT') LOOP >> TMP\createSequence.sql
echo 	IF rec.max_value like '999999999999999999%%' >> TMP\createSequence.sql
echo 		THEN rec.max_value := 999999999999999999 ; >> TMP\createSequence.sql
echo 	END IF; >> TMP\createSequence.sql
echo 	rec.LAST_NUMBER := rec.LAST_NUMBER+1; >> TMP\createSequence.sql
echo if rec.CACHE_SIZE = 0 then rec.CACHE_SIZE := 1; >> TMP\createSequence.sql
echo end if; >> TMP\createSequence.sql
echo 	dbms_output.put_line('create sequence if not exists '^|^|rec.sequence_owner^|^|'.'^|^|rec.SEQUENCE_NAME^|^|' increment by '^|^|rec.INCREMENT_BY^|^| >> TMP\createSequence.sql
echo 	' minvalue '^|^|rec.min_value^|^|' maxvalue '^|^|rec.MAX_VALUE^|^|' start with '^|^|rec.LAST_NUMBER^|^|' cache '^|^|rec.CACHE_SIZE^|^|';' >> TMP\createSequence.sql
echo 	); >> TMP\createSequence.sql
echo 	dbms_output.put_line('alter sequence if exists '^|^|rec.sequence_owner^|^|'.'^|^|rec.SEQUENCE_NAME^|^|' set schema '^|^|lv_schema_name^|^|';'); >> TMP\createSequence.sql
echo 	dbms_output.put_line('alter sequence if exists '^|^|rec.sequence_owner^|^|'.'^|^|rec.SEQUENCE_NAME^|^|' owner to '^|^|lv_schema_name^|^|';'); >> TMP\createSequence.sql
echo 	dbms_output.put_line('alter sequence if exists '^|^|rec.sequence_owner^|^|'.'^|^|rec.SEQUENCE_NAME^|^|' restart '^|^|rec.LAST_NUMBER^|^|';'); >> TMP\createSequence.sql
echo 	END LOOP; >> TMP\createSequence.sql
echo END; >> TMP\createSequence.sql

echo / >> TMP\createSequence.sql
echo spool off; >> TMP\createSequence.sql
echo prompt Done >> TMP\createSequence.sql
echo exit; >> TMP\createSequence.sql

SQLPLUS OT/wertuaL777@testdb @TMP\createSequence.sql