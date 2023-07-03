Скачаем файлы демонстрационной БД. Разархивируем, запустим скрипт разворачивания. 
```
wget https://edu.postgrespro.ru/demo-medium.zip

sudo apt-get install unzip

unzip demo-medium.zip

sudo -u postgres psql -f demo-medium-20170815.sql -U postgres
```
Откроем доступ к новой БД извне. 
```
sudo nano /etc/postgresql/15/main/pg_hba.conf
```

Возьмем в работу таблицу ticket_flights весом 245mb. 

Попробуем создать точно такую же таблицу, использовав при этом партицирование по диапазону значений, на основе индекса.
```
CREATE TABLE bookings.ticket_flights_1 (
	ticket_no bpchar(13) NOT NULL,
	flight_id int4 NOT NULL,
	fare_conditions varchar(10) NOT NULL,
	amount numeric(10, 2) NOT NULL,
	CONSTRAINT ticket_flights_amount_check1 CHECK ((amount >= (0)::numeric)),
	CONSTRAINT ticket_flights_fare_conditions_check1 CHECK (((fare_conditions)::text = ANY (ARRAY[('Economy'::character varying)::text, ('Comfort'::character varying)::text, ('Business'::character varying)::text]))),
	CONSTRAINT ticket_flights_pkey1 PRIMARY KEY (ticket_no, flight_id),
	CONSTRAINT ticket_flights_flight_id_fkey1 FOREIGN KEY (flight_id) REFERENCES bookings.flights(flight_id),
	CONSTRAINT ticket_flights_ticket_no_fkey1 FOREIGN KEY (ticket_no) REFERENCES bookings.tickets(ticket_no)
) partition by range (flight_id);
```

Затем создадим партиционные подтаблицы:
```
create table partition_1 partition of bookings.ticket_flights_1 for values from (minvalue) to (10000);
create table partition_2 partition of bookings.ticket_flights_1 for values from (10001) to (maxvalue);
create table default_partition_test2 partition of bookings.ticket_flights_1 default;
```

Вставим данные из дефолтной таблицы
```
insert into bookings.ticket_flights_1
select * from bookings.ticket_flights
```

Сравним план запроса к первой таблицы, и к новой(с партицими):
```
explain
select *
from bookings.ticket_flights
where flight_id  is null;

Index Scan using ticket_flights_pkey on ticket_flights  (cost=0.43..64498.93 rows=1 width=32)
  Index Cond: (flight_id IS NULL)
  
explain
select *
from bookings.ticket_flights_1
where flight_id  is null;

Result  (cost=0.00..0.00 rows=0 width=0)
  One-Time Filter: false 
```
Общий вывод: Секционирование очень мощный инструмент, позволяющий значительно ускорить доступ к данным. Отсутствие автоматического секционирования всегда можно обыграть с помощью джобов, триггеров и тд. На огромных таблицых, содержащих временные интервалы, 
выгодно использовать партиционирование по датам. Так, на одном из моих прошлых мест работы, мы использовали подобный подход к таблице, хранящей звонки абонентов. Партиционирование таблицы происходило ежемесячно. Тем самым удавалось накапливать огромной объем
данных, при этом избегая проблемы с извлечением и использованием. Также партиционирование помогает разделять таблицу на "логические модули" , чтобы несколько разработчиков могли работать одновременно и не мешать друг другу. К примеру, партиционирование по 
диапазону значений в таблице с клиентами (столбец с сегментом) позволяет разделить клиентов на сегменты бизнеса, чтобы один разработчик мог заниматься данными клиентов сегмента B2B, другой B2C и так далее.  