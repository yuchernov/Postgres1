## 1 создайте новый кластер PostgresSQL 14
```
sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-14
```
## 2 зайдите в созданный кластер под пользователем postgres
```
sudo -u postgres psql
```
## 3 создайте новую базу данных testdb
```
CREATE DATABASE testdb;
```
## 4 зайдите в созданную базу данных под пользователем postgres
```
\c testdb
```
## 5 создайте новую схему testnm
```
create schema testnm;
```
## 6 создайте новую таблицу t1 с одной колонкой c1 типа integer
```
CREATE TABLE testnm.t1 (c1 int);
```
## 7 вставьте строку со значением c1=1
```
INSERT INTO testnm.t1(c1) VALUES (1);
```
## 8 создайте новую роль readonly
```
CREATE ROLE readonly;
```
## 9 дайте новой роли право на подключение к базе данных testdb
```
GRANT CONNECT ON DATABASE testdb TO readonly;
```
## 10 дайте новой роли право на использование схемы testnm
```
GRANT USAGE ON SCHEMA testnm TO readonly;
```
## 11 дайте новой роли право на select для всех таблиц схемы testnm
```
GRANT SELECT ON ALL TABLES IN SCHEMA testnm TO readonly;
```
## 12 создайте пользователя testread с паролем test123
```
CREATE USER testread WITH PASSWORD 'test123';
```
## 13 дайте роль readonly пользователю testread
```
GRANT readonly TO testread;
```
## 14 зайдите под пользователем testread в базу данных testdb
```
\c testdb testread
```
## 15 сделайте select * from t1;
```
select * from testnm.t1;
```
## 16 получилось? (могло если вы делали сами не по шпаргалке и не упустили один существенный момент про который позже)
```
testdb=> select * from testnm.t1;
```
| c1 |
|----|
| 1  |
Все получилось. При создании таблицы была указана схеме. В запросе также схема указывается явно. Все работает
## 17 напишите что именно произошло в тексте домашнего задания
Все получилось.
## 18 у вас есть идеи почему? ведь права то дали?
Все получилось.
## 19 посмотрите на список таблиц
Все получилось.
## 20 подсказка в шпаргалке под пунктом 20
Все получилось.
## 21 а почему так получилось с таблицей (если делали сами и без шпаргалки то может у вас все нормально)
Все получилось.
## 22 вернитесь в базу данных testdb под пользователем postgres
## 23 удалите таблицу t1
```
drop table testnm.t1;
```
## 24 создайте ее заново но уже с явным указанием имени схемы testnm
Сделал так ранее.
## 25 вставьте строку со значением c1=1
Сделал так ранее.
## 26 зайдите под пользователем testread в базу данных testdb
Сделал так ранее.
## 27 сделайте select * from testnm.t1;
Сделал так ранее.
## 28 получилось?
Сделал так ранее.
## 29 есть идеи почему? если нет - смотрите шпаргалку
Сделал так ранее.
## 30 как сделать так чтобы такое больше не повторялось? если нет идей - смотрите шпаргалку
Создать синоним на эту таблицу, например. 
## 31 сделайте select * from testnm.t1;
```
select * from testnm.t1;
```
## 32 получилось?
```
ERROR:  permission denied for table t1
```
После пересоздания таблицы, слетели выданные ранее гранты к схеме. 
Выдам повторно под postgres
```
GRANT SELECT ON ALL TABLES IN SCHEMA testnm TO readonly;
```
## сделайте select * from testnm.t1;
## получилось?

Да
| c1 |
|----|
| 1  |

## 33 ура!

## 34 теперь попробуйте выполнить команду create table t2(c1 integer); insert into t2 values (2);
```
testdb=> create table t2(c1 integer);
CREATE TABLE
testdb=> insert into t2 values (2);
INSERT 0 1
```
## 35 а как так? нам же никто прав на создание таблиц и insert в них под ролью readonly?
По умолчанию, для схемы public есть гранты на создание таблицы. Их надо забрать. 
Если мы явно пропишем схему, получим ошибку
```
testdb=> create table testnm.t2(c1 integer);
ERROR:  permission denied for schema testnm
LINE 1: create table testnm.t2(c1 integer);
```
## 36 есть идеи как убрать эти права? если нет - смотрите шпаргалку
Надо забрать права на создание объектов из схемы пользователей.
## 37 если вы справились сами то расскажите что сделали и почему, если смотрели шпаргалку - объясните что сделали и почему выполнив указанные в ней команды
```
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
```
из под postgres 
## 38 теперь попробуйте выполнить команду create table t3(c1 integer); insert into t2 values (2);
```
testdb=> create table t4(t int);
ERROR:  permission denied for schema public
LINE 1: create table t4(t int);
```
## 39 расскажите что получилось и почему 
Получили ошибку, поскольку ранее забрали права на создание объектов в схеме пользователей