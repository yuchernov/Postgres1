rem шаблон , в который подставляются i, j. На выходе получается итоговая структура для таблиц

cd C:\Users\%username%\Desktop\SPOOL
echo prompt Start the unloading process... > TMP\tableddl.sql
echo set colsep ';' >> TMP\tableddl.sql
echo set echo off >> TMP\tableddl.sql
echo set feedback off >> TMP\tableddl.sql
echo set linesize 1000 >> TMP\tableddl.sql
echo set pagesize 0 >> TMP\tableddl.sql
echo set sqlprompt '' >> TMP\tableddl.sql
echo set trimspool on >> TMP\tableddl.sql
echo set headsep off >> TMP\tableddl.sql
echo set serveroutput on >> TMP\tableddl.sql

echo SPOOL C:\Users\%username%\Desktop\SPOOL\REP\%2.txt; >> TMP\tableddl.sql

echo DECLARE  >> TMP\tableddl.sql 
echo lv_table_name varchar2(150) := '%2'; >> TMP\tableddl.sql 
echo lv_schema_name varchar2(150) := '%1'; >> TMP\tableddl.sql 
echo lv_data_type varchar2(150); >> TMP\tableddl.sql 
echo lv_comma varchar2(100) := ','; >> TMP\tableddl.sql 
echo lv_UNIQUENESS varchar2(20) := ''; >> TMP\tableddl.sql 
echo lv_data_length varchar2(20); >> TMP\tableddl.sql
echo lv_DATA_DEFAULT varchar2(100); >> TMP\tableddl.sql
echo BEGIN  >> TMP\tableddl.sql 
echo dbms_output.put_line('CREATE TABLE IF NOT EXISTS '^|^|lv_schema_name^|^|'.'^|^|lv_table_name^|^|' ('); >> TMP\tableddl.sql 
echo FOR rec IN (SELECT COLUMN_NAME,DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, DATA_DEFAULT, COLUMN_ID, max(COLUMN_ID) OVER (PARTITION BY table_name, OWNER) AS max_column_id >> TMP\tableddl.sql 
echo FROM DBA_TAB_COLUMNS WHERE table_name = lv_table_name AND OWNER = lv_schema_name ORDER BY column_id) >> TMP\tableddl.sql 
echo LOOP  >> TMP\tableddl.sql 
echo IF rec.DATA_TYPE = 'VARCHAR2' THEN lv_data_type := 'VARCHAR'; >> TMP\tableddl.sql 
echo ELSIF rec.DATA_TYPE = 'NVARCHAR2' THEN lv_data_type := 'VARCHAR'; >> TMP\tableddl.sql
echo ELSIF rec.data_type = 'NUMBER' THEN lv_data_type := 'NUMERIC'; >> TMP\tableddl.sql 
echo ELSIF rec.data_type = 'CLOB' THEN lv_data_type := 'TEXT'; >> TMP\tableddl.sql 
echo ELSIF rec.data_type = 'BLOB' THEN lv_data_type := 'BYTEA'; >> TMP\tableddl.sql 
echo ELSIF rec.data_type LIKE 'TIMESTAMP%%' THEN lv_data_type := 'TIMESTAMP'; >> TMP\tableddl.sql 
echo ELSE lv_data_type := rec.data_type; >> TMP\tableddl.sql 
echo END IF; >> TMP\tableddl.sql 
echo IF rec.data_type = 'DATE' THEN lv_data_length := ''; lv_data_type := 'TIMESTAMP'; >> TMP\tableddl.sql 
echo ELSIF rec.data_type = 'CLOB' THEN lv_data_length := '';  >> TMP\tableddl.sql 
echo ELSIF rec.data_type = 'BLOB' THEN lv_data_length := '';  >> TMP\tableddl.sql 
echo ELSE lv_data_length := ' ('^|^|rec.data_length^|^|')'; >> TMP\tableddl.sql 
echo END IF; >> TMP\tableddl.sql 
echo IF rec.DATA_PRECISION IS NOT NULL THEN  >> TMP\tableddl.sql 
echo lv_data_length := ' ('^|^|rec.DATA_PRECISION^|^|','^|^|rec.DATA_SCALE^|^|')'; >> TMP\tableddl.sql 
echo END IF; >> TMP\tableddl.sql 
echo SELECT CASE WHEN rec.DATA_DEFAULT like '%%trunc(sysdate)%%' THEN 'current_date' >> TMP\tableddl.sql
echo WHEN rec.DATA_DEFAULT = 'sysdate' THEN 'current_timestamp(0)' ELSE rec.DATA_DEFAULT END INTO lv_DATA_DEFAULT FROM dual; >> TMP\tableddl.sql
echo IF lv_DATA_DEFAULT IS NOT NULL THEN  >> TMP\tableddl.sql
echo lv_comma := ' DEFAULT '^|^|lv_DATA_DEFAULT^|^|','; >> TMP\tableddl.sql
echo ELSE lv_comma := ','; >> TMP\tableddl.sql
echo END IF; >> TMP\tableddl.sql
echo IF rec.max_column_id = rec.column_id AND lv_DATA_DEFAULT IS NULL THEN  >> TMP\tableddl.sql
echo lv_comma := NULL; >> TMP\tableddl.sql
echo ELSIF rec.max_column_id = rec.column_id AND lv_DATA_DEFAULT IS NOT NULL THEN >> TMP\tableddl.sql
echo lv_comma := ' DEFAULT '^|^|lv_DATA_DEFAULT; >> TMP\tableddl.sql
echo END IF; >> TMP\tableddl.sql
echo dbms_output.put_line(rec.COLUMN_NAME^|^|' '^|^|lv_data_type^|^|lv_data_length^|^|lv_comma); >> TMP\tableddl.sql 
echo END LOOP; >> TMP\tableddl.sql 
echo dbms_output.put_line(') tablespace SOGECAP; alter table '^|^|lv_schema_name^|^|'.'^|^|lv_table_name^|^|' owner to %1;'); >> TMP\tableddl.sql 
echo FOR rec IN (SELECT CONSTRAINT_TYPE, CONSTRAINT_NAME, SEARCH_CONDITION FROM DBA_CONSTRAINTS WHERE owner = lv_schema_name AND table_name = lv_table_name) LOOP  >> TMP\tableddl.sql 
echo IF rec.CONSTRAINT_TYPE = 'C' AND rec.SEARCH_CONDITION LIKE '%%IS%%' THEN  >> TMP\tableddl.sql 
echo dbms_output.put_line('alter table '^|^|lv_schema_name^|^|'.'^|^|lv_table_name^|^|' alter column '^|^| >> TMP\tableddl.sql 
echo regexp_substr(rec.SEARCH_CONDITION, '[^^^"]+', 1, 1, 'i')^|^|' set '^|^| >> TMP\tableddl.sql 
echo regexp_substr(rec.SEARCH_CONDITION, '(.*?)(IS ^|$)+', 1, 2, 'i')^|^|';' >> TMP\tableddl.sql 
echo ); >> TMP\tableddl.sql 
echo ELSIF rec.CONSTRAINT_TYPE = 'C' AND rec.SEARCH_CONDITION NOT LIKE '%%IS%%NULL%%' THEN  >> TMP\tableddl.sql 
echo dbms_output.put_line('alter table '^|^|lv_schema_name^|^|'.'^|^|lv_table_name^|^|' alter column '^|^| >> TMP\tableddl.sql 
echo regexp_substr(rec.SEARCH_CONDITION, '[^^^"]+', 1, 1, 'i')^|^|' set '^|^| >> TMP\tableddl.sql 
echo regexp_substr(rec.SEARCH_CONDITION, '[^^^"]+', 1, 2, 'i')^|^|';' >> TMP\tableddl.sql 
echo ); >> TMP\tableddl.sql 
echo ELSIF rec.CONSTRAINT_TYPE = 'P' THEN >> TMP\tableddl.sql 
echo FOR rec2 IN (SELECT OWNER, INDEX_NAME, GENERATED, SECONDARY, FUNCIDX_STATUS, DROPPED, INDEX_TYPE, UNIQUENESS, TABLESPACE_NAME, >> TMP\tableddl.sql 
echo (SELECT LISTAGG(column_name,', ') WITHIN GROUP (ORDER BY COLUMN_POSITION) AS column_name FROM dba_ind_columns uic WHERE index_name = di.index_name and INDEX_OWNER = lv_schema_name) AS column_name  >> TMP\tableddl.sql 
echo FROM DBA_INDEXES di WHERE table_name = lv_table_name AND di.owner = lv_schema_name AND rec.CONSTRAINT_NAME = di.index_name) LOOP  >> TMP\tableddl.sql 
echo IF rec2.DROPPED = 'NO' THEN  >> TMP\tableddl.sql 
echo if rec2.INDEX_NAME = lv_table_name then rec2.INDEX_NAME := rec2.INDEX_NAME^|^|'_C'; end if; >> TMP\tableddl.sql 
echo dbms_output.put_line('alter table '^|^|lv_schema_name^|^|'.'^|^|lv_table_name^|^|' add constraint '^|^|rec2.INDEX_NAME^|^|' primary key ('^|^|rec2.column_name^|^|');'); >> TMP\tableddl.sql 
echo END IF; >> TMP\tableddl.sql 
echo END LOOP; >> TMP\tableddl.sql 
echo END IF; >> TMP\tableddl.sql 
echo END LOOP; >> TMP\tableddl.sql 
:: echo FOR rec IN (SELECT OWNER, NAME, TYPE, REFERENCED_OWNER, REFERENCED_NAME FROM DBA_DEPENDENCIES WHERE name = lv_table_name) LOOP  >> TMP\tableddl.sql 
:: echo IF rec.TYPE = 'SYNONYM' THEN  >> TMP\tableddl.sql 
:: echo dbms_output.put_line('SET SEARCH_PATH TO '^|^|rec.owner^|^|','^|^|rec.REFERENCED_OWNER^|^|';'); >> TMP\tableddl.sql 
:: echo END IF; >> TMP\tableddl.sql 
:: echo END LOOP; >> TMP\tableddl.sql 
echo FOR rec IN (SELECT di.INDEX_NAME, di.UNIQUENESS, di.TABLESPACE_NAME, LISTAGG(dic.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY di.INDEX_NAME) AS COLUMN_NAME FROM DBA_INDEXES di, DBA_IND_COLUMNS dic >> TMP\tableddl.sql 
echo WHERE di.INDEX_NAME = dic.index_name AND di.table_name = lv_table_name >> TMP\tableddl.sql 
echo AND status = 'VALID' AND owner = lv_schema_name AND INDEX_OWNER = lv_schema_name AND table_type = 'TABLE' GROUP BY di.INDEX_NAME, di.UNIQUENESS, di.TABLESPACE_NAME) LOOP  >> TMP\tableddl.sql 
echo IF rec.uniqueness = 'UNIQUE' THEN  >> TMP\tableddl.sql 
echo lv_UNIQUENESS := rec.uniqueness; >> TMP\tableddl.sql 
echo ELSE >> TMP\tableddl.sql 
echo lv_UNIQUENESS := ''; >> TMP\tableddl.sql 
echo END IF; >> TMP\tableddl.sql 
echo if rec.INDEX_NAME = lv_table_name then rec.INDEX_NAME := rec.INDEX_NAME^|^|'_C'; end if;>> TMP\tableddl.sql
echo dbms_output.put_line('CREATE '^|^|lv_UNIQUENESS^|^|' INDEX IF NOT EXISTS '^|^|rec.INDEX_NAME^|^|' on '^|^|lv_schema_name^|^|'.'^|^|lv_table_name^|^|' ('^|^|rec.column_name^|^|')'^|^|' TABLESPACE '^|^| >> TMP\tableddl.sql 
echo rec.tablespace_name^|^|';'); >> TMP\tableddl.sql 
echo dbms_output.put_line('alter index '^|^|lv_schema_name^|^|'.'^|^|rec.index_name^|^|' owner to '^|^|lv_schema_name^|^|';'); >> TMP\tableddl.sql 
echo END LOOP; >> TMP\tableddl.sql 

echo FOR rec IN (SELECT BASE_OBJECT_TYPE, TRIGGER_BODY, TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_OWNER, TABLE_NAME  >> TMP\tableddl.sql
echo FROM dba_triggers >> TMP\tableddl.sql
echo WHERE STATUS = 'ENABLED' AND TABLE_NAME = lv_table_name AND TABLE_OWNER = lv_schema_name) LOOP  >> TMP\tableddl.sql



echo dbms_output.put_line('create or replace function '^|^|lv_schema_name^|^|'.'^|^|rec.trigger_name^|^|'_'^|^|lv_table_name^|^|'()'); >> TMP\tableddl.sql
echo dbms_output.put_line('RETURNS trigger AS');  >> TMP\tableddl.sql
echo dbms_output.put_line('^$^$');  >> TMP\tableddl.sql
echo dbms_output.put_line(regexp_replace(regexp_replace(regexp_replace(rec.TRIGGER_BODY, 'from dual', '', 1, 0, 'i'), ':', '', 1, 0, 'i'), 'end;', 'RETURN NEW; END;', 1, 0, 'i'));  >> TMP\tableddl.sql

echo dbms_output.put_line('^$^$');  >> TMP\tableddl.sql
echo dbms_output.put_line('LANGUAGE ^'^'plpgsql^'^';'); >> TMP\tableddl.sql

echo dbms_output.put_line('DROP TRIGGER IF EXISTS '^|^|rec.trigger_name^|^|' ON '^|^|rec.TABLE_OWNER^|^|'.'^|^|lv_table_name^|^|';'); >> TMP\tableddl.sql

echo dbms_output.put_line('CREATE TRIGGER '^|^|rec.trigger_name^|^|' '^|^|regexp_substr(rec.TRIGGER_TYPE, '[^^ ]+', 1, 1, 'i')^|^|' '^|^|rec.TRIGGERING_EVENT^|^|' ON '^|^|rec.TABLE_OWNER^|^|'.'^|^|lv_table_name^|^|' FOR '^|^|regexp_substr(rec.TRIGGER_TYPE, ' (.*)$', 1, 1, 'i')^|^|' ');  >> TMP\tableddl.sql
echo dbms_output.put_line('execute procedure '^|^|lv_schema_name^|^|'.'^|^|rec.trigger_name^|^|'_'^|^|lv_table_name^|^|'(); END;'); >> TMP\tableddl.sql


echo END LOOP; >> TMP\tableddl.sql
echo END; >> TMP\tableddl.sql 
echo / >> TMP\tableddl.sql
echo spool off; >> TMP\tableddl.sql
echo prompt Done >> TMP\tableddl.sql
echo exit; >> TMP\tableddl.sql


SQLPLUS OT/wertuaL777@testdb @TMP\tableddl.sql