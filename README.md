# Postgres1
## 1 вопрос ##
**Запись во 2-й транзакции не видна, поскольку не был выполнен COMMIT в первой, после выполнения INSERT.

## 2 вопрос ##
**Видим, поскольку сделали COMMIT в первой сессии. Это обсуславливается уровнем изоляции read commited.

## 3 вопрос ##
**Нет.

## 4 вопрос ##
**Нет. Поскольку в режиме Repeatable Read видны только те данные, которые были зафиксированы до начала транзакции, но не видны незафиксированные данные и изменения, \произведённые другими транзакциями в процессе выполнения данной транзакции.

## 5 вопрос ##
**Запись появилась.








## создать ВМ с Ubuntu 20.04/22.04 или развернуть докер любым удобным способом ##

**	Использую ВМ с предыдущего ДЗ. Yandex Cloud Ubuntu 20.04

## поставить на нем Docker Engine ##

**	curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && rm get-docker.sh && sudo usermod -aG docker $USER

## сделать каталог /var/lib/postgres

**	sudo mkdir /var/lib/postgres

## развернуть контейнер с PostgreSQL 15 смонтировав в него /var/lib/postgresql

**	sudo docker network create pg-net	
**	sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /var/lib/postgres:/var/lib/postgresql/data postgres:15
	
## развернуть контейнер с клиентом postgres

**	sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres

## подключится из контейнера с клиентом к контейнеру с сервером и сделать таблицу с парой строк

**	postgres=# \c postgres
**	postgres=# CREATE TABLE test (i serial, amount int);
**	postgres=# INSERT INTO test(amount) VALUES (100);
**	postgres=# INSERT INTO test(amount) VALUES (500);

## подключится к контейнеру с сервером с ноутбука/компьютера извне инстансов GCP/ЯО/места установки докера

**	psql -p 5432 -U postgres -h 51.250.66.20 -d postgres -W	
**	Возникает ошибка Connection Refused, попробуем открыть порт 
**	Соединение извне невозможно при использовании Trial версии ВМ от YandexCloud. Админка групп доступа заблокирована. 

## удалить контейнер с сервером

**	sudo docker rm pg-server
**	Error response from daemon: You cannot remove a running container 629995c4f80662b5933d3d986e2f672584110a2e6c328caffa61ab1143085f49. Stop the container before attempting removal or force remove

**	Остановим контейнер.
**	sudo docker stop pg-server

**	Удалим 
**	sudo docker rm pg-server
	
## создать его заново

**	sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /var/lib/postgres:/var/lib/postgresql/data postgres:15

## подключится снова из контейнера с клиентом к контейнеру с сервером

**	sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres

## проверить, что данные остались на месте

**	\c postgres
**	select * from test;

**	 i | amount
**	---+--------
**	 1 |    100
**	 2 |    500
**	(2 rows)