## Настройте сервер так, чтобы в журнал сообщений сбрасывалась информация о блокировках, удерживаемых более 200 миллисекунд. Воспроизведите ситуацию, при которой в журнале появятся такие сообщения.
```
	ALTER SYSTEM SET log_lock_waits = on;
	SELECT pg_reload_conf();
	set deadlock_timeout='0.2s';


	CREATE TABLE accounts(
	  acc_no integer PRIMARY KEY,
	  amount numeric
	);
	INSERT INTO accounts VALUES (1,1000.00), (2,2000.00), (3,3000.00);
```
	В 1-й сессии:
```	
	BEGIN;
	UPDATE accounts SET amount = amount - 100.00 WHERE acc_no = 1;
```
	Во 2-й сессии:
```	
	BEGIN;
	UPDATE accounts SET amount = amount - 100.00 WHERE acc_no = 1;
```
	Отстрелим первую сессию. UPDATE выполнен. 
```
	sudo tail -n 10 /var/log/postgresql/postgresql-15-main.log
	2023-05-05 08:05:20.492 UTC [1290] postgres@postgres LOG:  process 1290 still waiting for ShareLock on transaction 62416 after 200.139 ms
	2023-05-05 08:05:20.492 UTC [1290] postgres@postgres DETAIL:  Process holding the lock: 1322. Wait queue: 1290.
	2023-05-05 08:05:20.492 UTC [1290] postgres@postgres CONTEXT:  while updating tuple (0,1) in relation "accounts"
	2023-05-05 08:05:20.492 UTC [1290] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 100.00 WHERE acc_no = 1;
	2023-05-05 08:05:32.163 UTC [1290] postgres@postgres LOG:  process 1290 acquired ShareLock on transaction 62416 after 11871.162 ms
	2023-05-05 08:05:32.163 UTC [1290] postgres@postgres CONTEXT:  while updating tuple (0,1) in relation "accounts"
	2023-05-05 08:05:32.163 UTC [1290] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 100.00 WHERE acc_no = 1;
```

## Смоделируйте ситуацию обновления одной и той же строки тремя командами UPDATE в разных сеансах. Изучите возникшие блокировки в представлении pg_locks и убедитесь, что все они понятны. Пришлите список блокировок и объясните, что значит каждая.
  
	Обновляем строку в 1-й сессии. Видим следующую картину. Мы удерживаем 1 строку в таблице.
```	
	1322	relation	accounts	RowExclusiveLock	true
	1322	transactionid	62421	ExclusiveLock	true
```
	Обновляем во 2-й сессии ту же строку
	Теперь мы видим, что помимо ожидания будущей блокировки строки , мы ожидаем завершения первой сессии. 
```
	1419	relation	accounts	RowExclusiveLock	true
	1419	tuple	accounts:12	ExclusiveLock	true
	1419	transactionid	62421	ShareLock	false
	1419	transactionid	62422	ExclusiveLock	true
```	  
	Обновляем в 3-й сессии ту же строку. Помимо нашей будущей блокировки, мы видим , что встали в очередь за блокировкой второй транзакции. Ожидая её завершения. 
```
	1394	relation	accounts	RowExclusiveLock
	1394	transactionid	62424	ExclusiveLock
	1394	tuple	accounts:12	ExclusiveLock
```
	Фактически, мы получили очередь.

## Воспроизведите взаимоблокировку трех транзакций. Можно ли разобраться в ситуации постфактум, изучая журнал сообщений?
При взаимоблокировки, мы получим сообщение такого типа

```
SQL Error [40P01]: ERROR: deadlock detected
  Подробности: Process 1419 waits for ShareLock on transaction 62433; blocked by process 1322.
Process 1322 waits for ShareLock on transaction 62434; blocked by process 1419.
  Подсказка: See server log for query details.
  Где: while updating tuple (0,25) in relation "accounts"
```
Проверим журнал сообщений.   
```
ychernov@qqq:~$ sudo tail -n 10 /var/log/postgresql/postgresql-15-main.log
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres DETAIL:  Process 5999 waits for ShareLock on transaction 62439; blocked by process 5998.
        Process 5998 waits for ShareLock on transaction 62440; blocked by process 5999.
        Process 5999: UPDATE accounts SET amount = amount + 10.00 WHERE acc_no = 1
        Process 5998: UPDATE accounts SET amount = amount + 100.00 WHERE acc_no = 2
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres HINT:  See server log for query details.
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres CONTEXT:  while updating tuple (0,25) in relation "accounts"
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 10.00 WHERE acc_no = 1
2023-05-05 08:52:39.309 UTC [5998] postgres@postgres LOG:  process 5998 acquired ShareLock on transaction 62440 after 8525.387 ms
2023-05-05 08:52:39.309 UTC [5998] postgres@postgres CONTEXT:  while updating tuple (0,2) in relation "accounts"
2023-05-05 08:52:39.309 UTC [5998] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 100.00 WHERE acc_no = 2
ychernov@qqq:~$ sudo tail -n 20 /var/log/postgresql/postgresql-15-main.log
bash: line 1: HXzwpO: command not found
2023-05-05 08:52:31.784 UTC [5998] postgres@postgres LOG:  process 5998 still waiting for ShareLock on transaction 62440 after 1000.120 ms
2023-05-05 08:52:31.784 UTC [5998] postgres@postgres DETAIL:  Process holding the lock: 5999. Wait queue: 5998.
2023-05-05 08:52:31.784 UTC [5998] postgres@postgres CONTEXT:  while updating tuple (0,2) in relation "accounts"
2023-05-05 08:52:31.784 UTC [5998] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 100.00 WHERE acc_no = 2
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres LOG:  process 5999 detected deadlock while waiting for ShareLock on transaction 62439 after 1000.144 ms
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres DETAIL:  Process holding the lock: 5998. Wait queue: .
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres CONTEXT:  while updating tuple (0,25) in relation "accounts"
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 10.00 WHERE acc_no = 1
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres ERROR:  deadlock detected
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres DETAIL:  Process 5999 waits for ShareLock on transaction 62439; blocked by process 5998.
        Process 5998 waits for ShareLock on transaction 62440; blocked by process 5999.
        Process 5999: UPDATE accounts SET amount = amount + 10.00 WHERE acc_no = 1
        Process 5998: UPDATE accounts SET amount = amount + 100.00 WHERE acc_no = 2
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres HINT:  See server log for query details.
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres CONTEXT:  while updating tuple (0,25) in relation "accounts"
2023-05-05 08:52:39.309 UTC [5999] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 10.00 WHERE acc_no = 1
2023-05-05 08:52:39.309 UTC [5998] postgres@postgres LOG:  process 5998 acquired ShareLock on transaction 62440 after 8525.387 ms
2023-05-05 08:52:39.309 UTC [5998] postgres@postgres CONTEXT:  while updating tuple (0,2) in relation "accounts"
2023-05-05 08:52:39.309 UTC [5998] postgres@postgres STATEMENT:  UPDATE accounts SET amount = amount + 100.00 WHERE acc_no = 2
```
Разобрав журнал, ситуацию можно исправить, поскольку можно отследить последовательность блокировок, которые привели к общему дедлоку. 	
	
## Могут ли две транзакции, выполняющие единственную команду UPDATE одной и той же таблицы (без where), заблокировать друг друга?
	
	Конечно, поскольку первый UPDATE будет удерживать строки всей таблицы, а вторая транзакция будет ожидать окончания первой. 
```	
	BEGIN;
	UPDATE accounts SET amount = amount - 100.00

	1322	relation	accounts	RowExclusiveLock
	1322	transactionid	62425	ExclusiveLock
	1419	relation	accounts	RowExclusiveLock
	1419	transactionid	62426	ExclusiveLock
	1419	transactionid	62425	ShareLock
	1419	tuple	accounts:2	ExclusiveLock
```