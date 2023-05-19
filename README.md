## развернуть виртуальную машину любым удобным способом

Использую VDS

## поставить на неё PostgreSQL 15 любым способом
```
sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15
```

## настроить кластер PostgreSQL 15 на максимальную производительность не обращая внимание на возможные проблемы с надежностью в случае аварийной перезагрузки виртуальной машины

Отключим параметр synchronous_commit
```
sudo -u postgres psql -c "ALTER SYSTEM SET synchronous_commit = off;"

sudo pg_ctlcluster 15 main reload
```
## нагрузить кластер через утилиту через утилиту pgbench (https://postgrespro.ru/docs/postgrespro/14/pgbench)
```
sudo -u postgres pgbench -i postgres
sudo -u postgres pgbench -P 1 -T 10 postgres

tps = 1673.548143 (without initial connection time)
```

## написать какого значения tps удалось достичь, показать какие параметры в какие значения устанавливали и почему

Достигли tps = 1673.548143, пробуем увеличить еще
Используя параметры конфигурации моей системы - 2 Гб RAM, 1 ядро CPU, минимальное число соединений 20, подберем через утилиту PGTUNE оптимальный конфиг:
```
max_connections = 20
shared_buffers = 512MB
effective_cache_size = 1536MB
maintenance_work_mem = 128MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 13107kB
min_wal_size = 2GB
max_wal_size = 8GB
```
К сожалению, достичь большого увеличения tps не удалось. 
```
tps = 1675.628033 (without initial connection time)
```
## Задание со *: аналогично протестировать через утилиту https://github.com/Percona-Lab/sysbench-tpcc (требует установки https://github.com/akopytov/sysbench) 
```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench

wget https://github.com/Percona-Lab/sysbench-tpcc/archive/refs/heads/master.zip

./tpcc.lua --pgsql-user=postgres --pgsql-db=postgres --time=120 --threads=10 --report-interval=1 --tables=10 --scale=100 --use_fk=0 --trx_level=RC --pgsql-password=[PASSWORD] --db-driver=pgsql prepare
```
БД наполнилась почти 100 Гб данных. 
```
./tpcc.lua --pgsql-user=postgres --pgsql-db=postgres --time=300 --threads=15 --report-interval=1 --tables=10 --scale=100 --pgsql-password=[PASSWORD] --db-driver=pgsql run

./tpcc.lua --pgsql-user=postgres --pgsql-db=postgres --time=300 --threads=15 --report-interval=1 --tables=10 --scale=100 --pgsql-password=[PASSWORD] --db-driver=pgsql cleanup
```

Результаты после 3 часов работы sysbench-tpcc для PostgreSQL с параметрами по умолчанию
TPS = 1800~

Это однозначно непредельные значения оптимизации, можно добиться и больших цифр, однако надо иметь представление о задаче, которую будет решать наш будущий кластер. Поскольку специфика работы является основным ориентиром для оптимизации.
Есть инструкции , которые больше подойдут для работы DWH хранилищ, там стараются оптимизировать процесс вставки, добавляя разные фичи, типо распределенных кластеров и тд. Совсем другой процесс оптимизации для создания OLTP базы. 