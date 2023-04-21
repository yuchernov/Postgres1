##    создайте виртуальную машину c Ubuntu 20.04/22.04 LTS в GCE/ЯО/Virtual Box/докере
	
##    поставьте на нее PostgreSQL 15 через sudo apt
```
sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15
```
##    проверьте что кластер запущен через sudo -u postgres pg_lsclusters
```	
15  main    5432 online postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log	
```	
##    зайдите из под пользователя postgres в psql и сделайте произвольную таблицу с произвольным содержимым
```	
    postgres=# create table test(c1 text);
    postgres=# insert into test values('1');
    \q
```	
##    остановите postgres например через sudo -u postgres pg_ctlcluster 15 main stop

```
sudo -u postgres pg_ctlcluster 15 main stop

Warning: stopping the cluster using pg_ctlcluster will mark the systemd unit as failed. Consider using systemctl:
  sudo systemctl stop postgresql@15-main

15  main    5432 down   postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log
```
	
 ##   создайте новый диск к ВМ размером 10GB
	
 ##   добавьте свеже-созданный диск к виртуальной машине - надо зайти в режим ее редактирования и дальше выбрать пункт attach existing disk
	
##    проинициализируйте диск согласно инструкции и подмонтировать файловую систему, только не забывайте менять имя диска на актуальное, в вашем случае это скорее всего будет /dev/sdb - https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux
```
sudo parted /dev/vdb mklabel gpt
sudo parted -a opt /dev/vdb mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L datapartition /dev/vdb1
sudo mount -o defaults /dev/vdb1 /mnt/data
sudo nano /etc/fstab
```
##    перезагрузите инстанс и убедитесь, что диск остается примонтированным (если не так смотрим в сторону fstab)
```	
df -h -x tmpfs
```
##    сделайте пользователя postgres владельцем /mnt/data - chown -R postgres:postgres /mnt/data/
```
sudo chown -R postgres:postgres /mnt/data/	
```	
##    перенесите содержимое /var/lib/postgres/14 в /mnt/data - mv /var/lib/postgresql/15/ mnt/data
```
sudo mv /var/lib/postgresql/15/ /mnt/data	
```	
##    попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 15 main start
```
sudo -u postgres pg_ctlcluster 15 main start
```	
##    напишите получилось или нет и почему
Получаем ошибку Error: /var/lib/postgresql/15/main is not accessible or does not exist
Не получилось, поскольку мы переместили postgres в другой раздел, но конфиг файл не поправили.	
	
##    задание: найти конфигурационный параметр в файлах раположенных в /etc/postgresql/15/main который надо поменять и поменяйте его. Напишите что и почему поменяли
```	
data_directory = '/mnt/data/15/main'            # use data in another directory	
```
Поменяли каталог, содержащий файлы данных 15 постгреса, поскольку перенесли их ранее на раздел другого жесткого диска.
	
##    попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 15 main start. Напишите получилось или нет и почему
	
Все получилось, поскольку изменили конфигурационный файл.
```
15  main    5432 online postgres /mnt/data/15/main /var/log/postgresql/postgresql-15-main.log
```
##    зайдите через через psql и проверьте содержимое ранее созданной таблицы
Данные на месте	
```
postgres=# select * from test;
```
| c1 |
|----|
| 1  |

 ##   задание со звездочкой : не удаляя существующий инстанс ВМ сделайте новый, поставьте на его PostgreSQL, удалите файлы с данными из /var/lib/postgres, перемонтируйте внешний диск который сделали ранее от первой виртуальной машины ко второй и запустите PostgreSQL на второй машине так чтобы он работал с данными на внешнем диске, расскажите как вы это сделали и что в итоге получилось.
```	
sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15
sudo rm -r 15
```
Отсоединяем диск от первой машины в UI.
Присоединяем ко второй машине в UI.

Убедимся в его подключении
```
lsblk
```

| NAME   | MAJ:MIN | RM | SIZE | RO | TYPE MOUNTPOINTS |
|--------|---------|----|------|----|------------------|
| vda    | 252:0   | 0  | 18G  | 0  | disk             |
| ├─vda1 | 252:1   | 0  | 1M   | 0  | part             |
| └─vda2 | 252:2   | 0  | 18G  | 0  | part             |
| vdb    | 252:16  | 0  | 20G  | 0  | disk             |
| └─vdb1 | 252:17  | 0  | 20G  | 0  | part             |

Проинициализируем и затем смонтируем подключенный диск
```
sudo mkdir -p /mnt/data
sudo mount -o defaults /dev/vdb1 /mnt/data
```
Далее изменяем конфиг файл постгреса 
```
data_directory = '/mnt/data/15/main'
```
Запускаем кластер
```
sudo -u postgres pg_ctlcluster 15 main start
```