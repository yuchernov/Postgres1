## Создаем ВМ/докер c ПГ.
Использую VDS
## Создаем БД, схему и в ней таблицу.
	```
	CREATE DATABASE testdb;
	
	\c testdb
	
	create schema testnm;

	CREATE TABLE testnm.test(c1 TEXT);
	```
## Заполним таблицы автосгенерированными 100 записями.
	```
	INSERT INTO testnm.test(c1) SELECT 'noname' FROM generate_series(1,100);
	```
## Под линукс пользователем Postgres создадим каталог для бэкапов
	```
	sudo -u postgres mkdir /etc/postgresql/sql
	```
## Сделаем логический бэкап используя утилиту COPY
	```
	COPY (SELECT * FROM testnm.test) TO '/etc/postgresql/sql/test.copy';
	```
## Восстановим в 2 таблицу данные из бэкапа.
	```
	CREATE TABLE testnm.test1(c1 TEXT);

	COPY testnm.test1 FROM '/etc/postgresql/sql/test.copy';
	```
## Используя утилиту pg_dump создадим бэкап с оглавлением в кастомном сжатом формате 2 таблиц
	```
	sudo -u postgres pg_dump -Fc -t testnm.test1 -t testnm.test testdb > /tmp/testdb.dump
	```
## Используя утилиту pg_restore восстановим в новую БД только вторую таблицу!
	```
	CREATE DATABASE testdb1;
	
	create schema testnm;
	
	sudo -u postgres pg_restore -d testdb1 -t test1 testdb.dump
	
	postgres=# \c testdb1
	You are now connected to database "testdb1" as user "postgres".
	testdb1=# select count(1) from testnm.test1;
	 count
	-------
	   100
	(1 row)
	```