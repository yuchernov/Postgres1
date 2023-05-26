# На 1 ВМ создаем таблицы test для записи, test2 для запросов на чтение.

	Установим 15 постгрес
	```
	sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15
	```
	Создадим новую базу данных
	```
	create database testdb;
	```
	Откроем доступ к новой базе данных для других ВМ. Изменим параметры
	```
	sudo nano /etc/postgresql/15/main/pg_hba.conf

	sudo nano /etc/postgresql/15/main/postgresql.conf
	```
	На текущей машине создаим 2 таблицы.
	```
	\с testdb
	
	ALTER SYSTEM SET wal_level = logical;

	CREATE TABLE test(
	  acc_no integer,
	  amount numeric
	);

	CREATE TABLE test2(
	  acc_no integer,
	  amount numeric
	);
	```
	Перезапустим кластер

# Создаем публикацию таблицы test и подписываемся на публикацию таблицы test2 с ВМ №2.
	```
	CREATE PUBLICATION test_pub FOR TABLE test;
	\password pas123
	```
	Создадим подписку на test2 на 2 ВМ.
	```
	CREATE SUBSCRIPTION test_sub 
	CONNECTION 'host=10.128.0.34 port=5432 user=postgres password=pas123 dbname=testdb' 
	PUBLICATION test_pub1 WITH (copy_data = false);
	```

# На 2 ВМ создаем таблицы test2 для записи, test для запросов на чтение.

	Откроем доступ к новой базе данных для других ВМ. Изменим параметры
	```
	sudo nano /etc/postgresql/15/main/pg_hba.conf

	sudo nano /etc/postgresql/15/main/postgresql.conf
	```
	Переходим на 2 ВМ

	Создадим новую базу данных
	```
	create database testdb;
	```	
	Создадим таблицы
	```
	CREATE TABLE test(
	  acc_no integer,
	  amount numeric
	);	
	
	CREATE TABLE test2(
	  acc_no integer,
	  amount numeric
	);	
	
	ALTER SYSTEM SET wal_level = logical;
	```
	рестарт кластера.

# Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1.
	```
	CREATE PUBLICATION test_pub1 FOR TABLE test2;
	\password pas123
	
	CREATE SUBSCRIPTION test_sub 
	CONNECTION 'host=10.128.0.10 port=5432 user=postgres password=pas123 dbname=testdb' 
	PUBLICATION test_pub WITH (copy_data = false);	
	```
# 3 ВМ использовать как реплику для чтения и бэкапов (подписаться на таблицы из ВМ №1 и №2 ).

	Установим 15 постгрес
	```
	sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15
	```
	Создадим новую базу данных
	```
	create database testdb;
	```	
	Создадим таблицы
	```
	CREATE TABLE test(
	  acc_no integer,
	  amount numeric
	);	
	
	CREATE TABLE test2(
	  acc_no integer,
	  amount numeric
	);	
	
	CREATE SUBSCRIPTION test_sub 
	CONNECTION 'host=10.128.0.10 port=5432 user=postgres password=pas123 dbname=testdb' 
	PUBLICATION test_pub WITH (copy_data = false);		

	CREATE SUBSCRIPTION test_sub1
	CONNECTION 'host=10.128.0.34 port=5432 user=postgres password=pas123 dbname=testdb' 
	PUBLICATION test_pub1 WITH (copy_data = false);
	```