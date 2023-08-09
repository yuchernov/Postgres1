prompt Start the unloading process... 
set colsep '' 
set echo off 
set feedback off 
set linesize 15000 
set pagesize 0 
set sqlprompt '' 
set trimspool on 
set headsep off 
set long 200000 
set longchunksize 200000 
set pages 0 
set termout off  
set wrap off  
set serveroutput on 
alter session set nls_date_format="yyyy-mm-dd hh24:mi:ss"; 
alter session set nls_timestamp_format="yyyy-mm-dd hh24:mi:ss"; 
SPOOL C:\Users\Yury\Desktop\SPOOL\CSV\ORDER_ITEMS.csv;  
DECLARE  
TYPE type_record IS TABLE OF OT.ORDER_ITEMS%ROWTYPE; 
rec type_record; 
CURSOR main_cur_for_import IS select * from OT.ORDER_ITEMS    ; 
BEGIN 
OPEN main_cur_for_import; 
LOOP 
FETCH main_cur_for_import BULK COLLECT 
INTO rec LIMIT 1000; 
EXIT WHEN rec.count = 0; 
for i IN 1..rec.count LOOP 
dbms_output.put_line(rec(i).ORDER_ID||''||rec(i).ITEM_ID||''||rec(i).PRODUCT_ID||''||rec(i).QUANTITY||''||rec(i).UNIT_PRICE);END LOOP; 
END LOOP; 
CLOSE main_cur_for_import; 
END; 
/ 
 
spool off; 
prompt Done 
exit; 
