##Создать инстанс ВМ с 2 ядрами и 4 Гб ОЗУ и SSD 10GB
```
Создал
```
##Установить на него PostgreSQL 15 с дефолтными настройками
```
sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15
```
##Создать БД для тестов: выполнить pgbench -i postgres
```
sudo -u postgres pgbench -i postgres
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.07 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 2.12 s (drop tables 0.00 s, create tables 0.01 s, client-side generate 0.68 s, vacuum 0.04 s, primary keys 1.38 s).
```
##Запустить pgbench -c8 -P 6 -T 60 -U postgres postgres
```
sudo -u postgres pgbench -c8 -P 6 -T 60 -U postgres postgres
starting vacuum...end.
progress: 6.0 s, 638.3 tps, lat 12.480 ms stddev 7.579, 0 failed
progress: 12.0 s, 453.5 tps, lat 17.629 ms stddev 12.811, 0 failed
progress: 18.0 s, 472.3 tps, lat 16.952 ms stddev 11.166, 0 failed
progress: 24.0 s, 384.2 tps, lat 20.785 ms stddev 20.898, 0 failed
progress: 30.0 s, 575.3 tps, lat 13.933 ms stddev 8.312, 0 failed
progress: 36.0 s, 610.0 tps, lat 13.108 ms stddev 9.295, 0 failed
progress: 42.0 s, 578.0 tps, lat 13.815 ms stddev 8.460, 0 failed
progress: 48.0 s, 434.5 tps, lat 18.449 ms stddev 13.908, 0 failed
progress: 54.0 s, 368.3 tps, lat 21.710 ms stddev 23.768, 0 failed
progress: 60.0 s, 477.2 tps, lat 16.705 ms stddev 54.371, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 29958
number of failed transactions: 0 (0.000%)
latency average = 16.022 ms
latency stddev = 21.082 ms
initial connection time = 16.481 ms
tps = 499.237404 (without initial connection time)
```
##Применить параметры настройки PostgreSQL из прикрепленного к материалам занятия файла
```
sudo nano /etc/postgresql/15/main/postgresql.conf
sudo -u postgres pg_ctlcluster 15 main stop
sudo -u postgres pg_ctlcluster 15 main start
```
##Протестировать заново
```
starting vacuum...end.
progress: 6.0 s, 544.3 tps, lat 14.626 ms stddev 8.865, 0 failed
progress: 12.0 s, 598.7 tps, lat 13.363 ms stddev 8.137, 0 failed
progress: 18.0 s, 530.7 tps, lat 15.067 ms stddev 10.023, 0 failed
progress: 24.0 s, 455.3 tps, lat 17.571 ms stddev 11.427, 0 failed
progress: 30.0 s, 447.8 tps, lat 17.778 ms stddev 17.153, 0 failed
progress: 36.0 s, 546.0 tps, lat 14.707 ms stddev 10.039, 0 failed
progress: 42.0 s, 673.3 tps, lat 11.878 ms stddev 6.785, 0 failed
progress: 48.0 s, 620.7 tps, lat 12.862 ms stddev 8.831, 0 failed
progress: 54.0 s, 429.8 tps, lat 18.639 ms stddev 11.898, 0 failed
progress: 60.0 s, 426.0 tps, lat 18.762 ms stddev 18.976, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 31644
number of failed transactions: 0 (0.000%)
latency average = 15.163 ms
latency stddev = 11.562 ms
initial connection time = 18.030 ms
tps = 527.270634 (without initial connection time)
```
##Что изменилось и почему?

После изменения настроек кластера, можно видеть, что за 60 секунд работы, с 8 одновременными соединениями, кластер обработал 31 644 транзакций с пропускной способностью примерно 527 транзакций в секунду.
Производительность (по скорости обработки транзакций) выросла примерно на 5%. Я так понимаю, результатом увеличения скорости обработки данных, стало увеличение общего объема буффера памяти и диска. 

##Создать таблицу с текстовым полем и заполнить случайными или сгенерированными данным в размере 1млн строк
```
CREATE TABLE test(c1 TEXT);
INSERT INTO test(c1) SELECT 'noname' FROM generate_series(1,1000000);
```
##Посмотреть размер файла с таблицей
```
select pg_size_pretty(pg_total_relation_size('test'));
```
Размер файла 35 Мб.

##5 раз обновить все строчки и добавить к каждой строчке любой символ
```
update test set c1 = c1 ||1; --69MB
update test set c1 = c1 ||2; --77MB
update test set c1 = c1 ||3; --119MB
update test set c1 = c1 ||4; --127MB
update test set c1 = c1 ||5; --127MB. Практически после апдейта был выполнен автовакуум.
```
##Посмотреть количество мертвых строчек в таблице и когда последний раз приходил автовакуум
```
SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum FROM pg_stat_user_TABLEs WHERE relname = 'test';
```
##Подождать некоторое время, проверяя, пришел ли автовакуум

Прошел. Практически после апдейта был выполнен автовакуум.

##5 раз обновить все строчки и добавить к каждой строчке любой символ

Размер 169 Мб.

##Отключить Автовакуум на конкретной таблице
```
ALTER TABLE test SET (autovacuum_enabled = off);
```
##10 раз обновить все строчки и добавить к каждой строчке любой символ
```
update test set c1 = c1 ||1; 
update test set c1 = c1 ||2; 
update test set c1 = c1 ||3; 
update test set c1 = c1 ||4; 
update test set c1 = c1 ||5;
update test set c1 = c1 ||6; 
update test set c1 = c1 ||7; 
update test set c1 = c1 ||8; 
update test set c1 = c1 ||9; 
update test set c1 = c1 ||10;
```
##Посмотреть размер файла с таблицей

Размер 570 Мб.

##Объясните полученный результат

Результат является накопительным , поскольку был выполнен ряд UPDATE, которые повлекли за собой расширение структуры файла таблицы. Для того чтобы вернуться к изначальному размеру в 35 МБ, необходимо выполнить полный вакуум, 
который в процессе отработки полностью пересоздаст таблицу, тем самым, удалив и "дырки" , полученные в результате апдейтов. 

##Задание со *: Написать анонимную процедуру, в которой в цикле 10 раз обновятся все строчки в искомой таблице. Не забыть вывести номер шага цикла.
```
DO $$
BEGIN
        FOR i IN 0..9 LOOP
        update test set c1 = c1 || 1;
		RAISE NOTICE 'id = %', i;
    END LOOP;
END$$;
```