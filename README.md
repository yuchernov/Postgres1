# Heading Реализация инструмента для миграции Oracle - PostgreSQL

Проблематика – большинство существующих инструментов написаны под Unix платформы. В данной работе, я описываю самописный инструмент под Windows, который позволяет смигрировать базу данных Oracle (Windows) в Postgres (Ubuntu).

### Установка Oracle
Сперва развернем Oracle на нашей локальной Windows машине. На официальном сайте представлена вся необходимая документации об установке Oracle под разные ОС. К сожалению, моя ранее созданная УЗ в Oracle была удалена. Также сейчас недоступна регистрация для граждан РФ и республики Беларусь. Пришлось регистрировать новую УЗ, используя VPN. Только после этого стала доступна ссылка на скачивание ознакомительной версии Oracle 19C под Windows. Oracle Database 19c for Microsoft Windows x64 (64-bit). Параметры при установке не меняю, использую стандартные.
![](https://github.com/yuchernov/Postgres1/blob/main/SPOOL/1.jpg)
После установки сервера, поднимем тестовый инстанс Oracle. Не забываем изменить пароль для УЗ system.
Подключаемся к нашей БД:
![](https://github.com/yuchernov/Postgres1/blob/main/SPOOL/2.jpg)
После проверки работоспособности нашего инстанса, можем приступить к созданию тестовой структуры.
### Наполнение БД тестовыми данными
Тестовые данные беру отсюда https://www.oracletutorial.com/getting-started/oracle-sample-database/. Выполним SQL скрипты для подготовки данных из sqlplus. Прикладываю также архив с sql файлами.
### Подготовка к миграции
Первым делом, подготовим список таблиц, DDL которых нам необходимо получить. Сделаем файл tables.txt. Используем перенос строки в качестве разделителя. Затем начинаем разработку основного bat файла, который будет вызывать наши скрипты миграции. На первом этапе, основной скрипт запуска будет выглядеть следующим образом:
```
for %%i in ("start.bat") do call %%i|| exit /b 1 rem подготовка DDL DCD для миграции
goto end
-----------
call "^start.bat"
-----------
:end
```
Данный скрипт будет основным, туда мы будем добавлять новые обработчики, по ходу их разработки. На данном этапе, скрипт тянет за собой только одну команду:
```
for /F "tokens=1-2 delims=." %%i in (E:\Work\Postgres\tables.txt) do tableddl.bat %%i %%j
```
Файл tableddl содержит в себе разработанный шаблон для построения DDL таблиц. В нем реализован полноценный маппинг DDL Oracle на DDL Postgres. Описаны: приведения типов, системные переменные, порядок столбцов, разделители, а также констрейнты и триггеры. Даже учтена возможность использования tablespace, что абсолютно не важно для Postgres, но для Oracle имеет значение. На выходе мы получаем структуру таблицы под Postgres. Приведу в качестве примера структуру одной из таблиц, обработанную данным скриптом.
```
CREATE TABLE IF NOT EXISTS OT.CONTACTS (
CONTACT_ID NUMERIC (22) DEFAULT "OT"."ISEQ$$_73085".nextval,
FIRST_NAME VARCHAR (255),
LAST_NAME VARCHAR (255),
EMAIL VARCHAR (255),
PHONE VARCHAR (20),
CUSTOMER_ID NUMERIC (22)
) tablespace SOGECAP; alter table OT.CONTACTS owner to OT;
alter table OT.CONTACTS alter column CONTACT_ID set NOT NULL;
alter table OT.CONTACTS alter column FIRST_NAME set NOT NULL;
alter table OT.CONTACTS alter column LAST_NAME set NOT NULL;
alter table OT.CONTACTS alter column EMAIL set NOT NULL;
alter table OT.CONTACTS add constraint SYS_C007456 primary key (CONTACT_ID);
CREATE UNIQUE INDEX IF NOT EXISTS SYS_C007456 on OT.CONTACTS (CONTACT_ID) TABLESPACE USERS;
alter index OT.SYS_C007456 owner to OT;
```
А так выглядит скрипт формирования секвенций:
```
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
```
Самым объемным вышел скрипт формирования csv файлов для последующего импорта в postgres. Фактически, он разбит на 4 части – поиск крупных и длинных таблиц, файл обработки csv, файл запуска обработки. После выполнения данного скрипта, мы получаем готовые csv файлы с данными из наших таблиц. Тем самым, структура таблиц, данные, секвенции готовы к последующей передаче в postgres.
### Загрузка данных в PostgreSQL
Первым делом развернем кластер 15 постгрес.
```
sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15
```
Затем откроем возможность внешнего подключения. Добавим метод авторизации для новой БД, а также изменим параметр listen_addresses в postgresql.conf
```
sudo nano /etc/postgresql/15/main/pg_hba.conf
sudo nano /etc/postgresql/15/main/postgresql.conf
```
Не забудем подготовить нашу базу postgres. Создадим нужные tablespace, прогоним индексы. Этот процесс также можно автоматизировать включив скрипты в наш основной обработчик. Напишем обработчик, который возьмет DDL наших таблиц и прокинет в Postgresql
```
set logname=%date:~0,2%%date:~3,2%%date:~6,8%_%time:~0,2%%time:~3,2%%time:~6,2%
set logname=%logname: =%

set pg_sql_path=%C:\Program Files\PostgreSQL\15\bin\psql.exe%
:: type nul > C:\Users\%username%\Desktop\SPOOL\TMP\log.txt
for /f "delims=" %%i in ('dir C:\Users\%username%\Desktop\SPOOL\REP /b/a-d') do (
echo TABLE: %%i >> C:\Users\%username%\Desktop\SPOOL\LOG\add_tables_%logname%.txt
"%pg_sql_path%" -h 185.209.162.254 -d demo -U postgres -p 5432 -f "C:\Users\%username%\Desktop\SPOOL\REP\%%i" >> C:\Users\%username%\Desktop\SPOOL\LOG\add_tables_%logname%.txt 2>>&1
)
```
Зайдем в нашу БД, убедимся что таблицы были созданы.
![](https://github.com/yuchernov/Postgres1/blob/main/SPOOL/3.jpg)
Приступим к загрузке данных в таблицы. У нас есть два варианта - более простой и сложный. Простой заключается в том, что мы заранее помещаем CSV файлы с данными, сформированные на прошлом шаге, либо мы шарим эти файлы на windows машине с oracle и отдаем по сети. В данном описании я использую простой способ. Перемещаю CSV файлы на машину с postgres. 
```
COPY OT.CONTACTS FROM '/etc/postgresql/sql/Postgres1-main/SPOOL/CSV/CONTACTS.csv' WITH QUOTE E'\026' DELIMITER E'\007' CSV encoding 'windows1251' 
```
Проверим таблицу, убедимся, что данные загружены. 
![](https://github.com/yuchernov/Postgres1/blob/main/SPOOL/4.jpg)
Таким образом, реализован механизм по передачи таблиц из Oracle в Postgres. Главным преимуществом данного инструмента служит независимость от сторонних программ и библиотек, что довольно критично при работе в инфрастуктуре закрытого типа. 
С помощью инструмента мы забрали структуру таблиц из Oracle, подготовили маппинг для формирования DDL под Postgres , а также перенесли данные из таблиц. К сожалению, данный инструмент не может быть использован для переноса кода plsql в postgres, поскольку 
нет возможности учесть всю специфику psql в pgsql, однако, мы без особоых трудов перенесли наши таблицы и их данные в Postgres. 