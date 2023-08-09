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
SPOOL C:\Users\Yury\Desktop\SPOOL\REP\WAREHOUSES.txt; 
DECLARE   
lv_table_name varchar2(150) := 'WAREHOUSES';  
lv_schema_name varchar2(150) := 'OT';  
lv_data_type varchar2(150);  
lv_comma varchar2(100) := ',';  
lv_UNIQUENESS varchar2(20) := '';  
lv_data_length varchar2(20); 
lv_DATA_DEFAULT varchar2(100); 
BEGIN   
dbms_output.put_line('CREATE TABLE IF NOT EXISTS '||lv_schema_name||'.'||lv_table_name||' (');  
FOR rec IN (SELECT COLUMN_NAME,DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, DATA_DEFAULT, COLUMN_ID, max(COLUMN_ID) OVER (PARTITION BY table_name, OWNER) AS max_column_id  
FROM DBA_TAB_COLUMNS WHERE table_name = lv_table_name AND OWNER = lv_schema_name ORDER BY column_id)  
LOOP   
IF rec.DATA_TYPE = 'VARCHAR2' THEN lv_data_type := 'VARCHAR';  
ELSIF rec.DATA_TYPE = 'NVARCHAR2' THEN lv_data_type := 'VARCHAR'; 
ELSIF rec.data_type = 'NUMBER' THEN lv_data_type := 'NUMERIC';  
ELSIF rec.data_type = 'CLOB' THEN lv_data_type := 'TEXT';  
ELSIF rec.data_type = 'BLOB' THEN lv_data_type := 'BYTEA';  
ELSIF rec.data_type LIKE 'TIMESTAMP%' THEN lv_data_type := 'TIMESTAMP';  
ELSE lv_data_type := rec.data_type;  
END IF;  
IF rec.data_type = 'DATE' THEN lv_data_length := ''; lv_data_type := 'TIMESTAMP';  
ELSIF rec.data_type = 'CLOB' THEN lv_data_length := '';   
ELSIF rec.data_type = 'BLOB' THEN lv_data_length := '';   
ELSE lv_data_length := ' ('||rec.data_length||')';  
END IF;  
IF rec.DATA_PRECISION IS NOT NULL THEN   
lv_data_length := ' ('||rec.DATA_PRECISION||','||rec.DATA_SCALE||')';  
END IF;  
SELECT CASE WHEN rec.DATA_DEFAULT like '%trunc(sysdate)%' THEN 'current_date' 
WHEN rec.DATA_DEFAULT = 'sysdate' THEN 'current_timestamp(0)' ELSE rec.DATA_DEFAULT END INTO lv_DATA_DEFAULT FROM dual; 
IF lv_DATA_DEFAULT IS NOT NULL THEN  
lv_comma := ' DEFAULT '||lv_DATA_DEFAULT||','; 
ELSE lv_comma := ','; 
END IF; 
IF rec.max_column_id = rec.column_id AND lv_DATA_DEFAULT IS NULL THEN  
lv_comma := NULL; 
ELSIF rec.max_column_id = rec.column_id AND lv_DATA_DEFAULT IS NOT NULL THEN 
lv_comma := ' DEFAULT '||lv_DATA_DEFAULT; 
END IF; 
dbms_output.put_line(rec.COLUMN_NAME||' '||lv_data_type||lv_data_length||lv_comma);  
END LOOP;  
dbms_output.put_line(') tablespace SOGECAP; alter table '||lv_schema_name||'.'||lv_table_name||' owner to OT;');  
FOR rec IN (SELECT CONSTRAINT_TYPE, CONSTRAINT_NAME, SEARCH_CONDITION FROM DBA_CONSTRAINTS WHERE owner = lv_schema_name AND table_name = lv_table_name) LOOP   
IF rec.CONSTRAINT_TYPE = 'C' AND rec.SEARCH_CONDITION LIKE '%IS%' THEN   
dbms_output.put_line('alter table '||lv_schema_name||'.'||lv_table_name||' alter column '||  
regexp_substr(rec.SEARCH_CONDITION, '[^"]+', 1, 1, 'i')||' set '||  
regexp_substr(rec.SEARCH_CONDITION, '(.*?)(IS |$)+', 1, 2, 'i')||';'  
);  
ELSIF rec.CONSTRAINT_TYPE = 'C' AND rec.SEARCH_CONDITION NOT LIKE '%IS%NULL%' THEN   
dbms_output.put_line('alter table '||lv_schema_name||'.'||lv_table_name||' alter column '||  
regexp_substr(rec.SEARCH_CONDITION, '[^"]+', 1, 1, 'i')||' set '||  
regexp_substr(rec.SEARCH_CONDITION, '[^"]+', 1, 2, 'i')||';'  
);  
ELSIF rec.CONSTRAINT_TYPE = 'P' THEN  
FOR rec2 IN (SELECT OWNER, INDEX_NAME, GENERATED, SECONDARY, FUNCIDX_STATUS, DROPPED, INDEX_TYPE, UNIQUENESS, TABLESPACE_NAME,  
(SELECT LISTAGG(column_name,', ') WITHIN GROUP (ORDER BY COLUMN_POSITION) AS column_name FROM dba_ind_columns uic WHERE index_name = di.index_name and INDEX_OWNER = lv_schema_name) AS column_name   
FROM DBA_INDEXES di WHERE table_name = lv_table_name AND di.owner = lv_schema_name AND rec.CONSTRAINT_NAME = di.index_name) LOOP   
IF rec2.DROPPED = 'NO' THEN   
if rec2.INDEX_NAME = lv_table_name then rec2.INDEX_NAME := rec2.INDEX_NAME||'_C'; end if;  
dbms_output.put_line('alter table '||lv_schema_name||'.'||lv_table_name||' add constraint '||rec2.INDEX_NAME||' primary key ('||rec2.column_name||');');  
END IF;  
END LOOP;  
END IF;  
END LOOP;  
FOR rec IN (SELECT di.INDEX_NAME, di.UNIQUENESS, di.TABLESPACE_NAME, LISTAGG(dic.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY di.INDEX_NAME) AS COLUMN_NAME FROM DBA_INDEXES di, DBA_IND_COLUMNS dic  
WHERE di.INDEX_NAME = dic.index_name AND di.table_name = lv_table_name  
AND status = 'VALID' AND owner = lv_schema_name AND INDEX_OWNER = lv_schema_name AND table_type = 'TABLE' GROUP BY di.INDEX_NAME, di.UNIQUENESS, di.TABLESPACE_NAME) LOOP   
IF rec.uniqueness = 'UNIQUE' THEN   
lv_UNIQUENESS := rec.uniqueness;  
ELSE  
lv_UNIQUENESS := '';  
END IF;  
if rec.INDEX_NAME = lv_table_name then rec.INDEX_NAME := rec.INDEX_NAME||'_C'; end if;
dbms_output.put_line('CREATE '||lv_UNIQUENESS||' INDEX IF NOT EXISTS '||rec.INDEX_NAME||' on '||lv_schema_name||'.'||lv_table_name||' ('||rec.column_name||')'||' TABLESPACE '||  
rec.tablespace_name||';');  
dbms_output.put_line('alter index '||lv_schema_name||'.'||rec.index_name||' owner to '||lv_schema_name||';');  
END LOOP;  
FOR rec IN (SELECT BASE_OBJECT_TYPE, TRIGGER_BODY, TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_OWNER, TABLE_NAME  
FROM dba_triggers 
WHERE STATUS = 'ENABLED' AND TABLE_NAME = lv_table_name AND TABLE_OWNER = lv_schema_name) LOOP  
dbms_output.put_line('create or replace function '||lv_schema_name||'.'||rec.trigger_name||'_'||lv_table_name||'()'); 
dbms_output.put_line('RETURNS trigger AS');  
dbms_output.put_line('$$');  
dbms_output.put_line(regexp_replace(regexp_replace(regexp_replace(rec.TRIGGER_BODY, 'from dual', '', 1, 0, 'i'), ':', '', 1, 0, 'i'), 'end;', 'RETURN NEW; END;', 1, 0, 'i'));  
dbms_output.put_line('$$');  
dbms_output.put_line('LANGUAGE ''plpgsql'';'); 
dbms_output.put_line('DROP TRIGGER IF EXISTS '||rec.trigger_name||' ON '||rec.TABLE_OWNER||'.'||lv_table_name||';'); 
dbms_output.put_line('CREATE TRIGGER '||rec.trigger_name||' '||regexp_substr(rec.TRIGGER_TYPE, '[^ ]+', 1, 1, 'i')||' '||rec.TRIGGERING_EVENT||' ON '||rec.TABLE_OWNER||'.'||lv_table_name||' FOR '||regexp_substr(rec.TRIGGER_TYPE, ' (.*)$', 1, 1, 'i')||' ');  
dbms_output.put_line('execute procedure '||lv_schema_name||'.'||rec.trigger_name||'_'||lv_table_name||'(); END;'); 
END LOOP; 
END;  
/ 
spool off; 
prompt Done 
exit; 
