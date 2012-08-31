# mysql master-slave demo:
Basici mysql cluster replication (master-slave) created via puppet.

## VM description:

 - OS: Scientific linux 6
 - master vm: mammoth01
 - slave vm: mammoth02

## Master Node step by step

### 1. Install mysql server:

 - install mysql-server (yum install mysql-server)
 - set a password for mysql root user: /usr/bin/mysqladmin -u root password "password"
 - configure firewall (default port 3306)

### 2. Config /etc/my.cnf section [mysqld]

    log-bin=mysql-bin
    server-id=1

and restart mysql master (/etc/init.d/mysqld restart)

### 3. Create Slave user and check Master status:

    grant replication slave, replication client on *.* to 'repl'@'%' identified by "password"; flush provoleges;

### 4. Check Master status:

    SHOW MASTER STATUS;

Example output:

    +------------------+----------+--------------+------------------+
    | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
    +------------------+----------+--------------+------------------+
    | mysql-bin.000002 |      106 |              |                  |
    +------------------+----------+--------------+------------------+

### 4. Backup database and transfer to slave:

    FLUSH TABLES WITH READ LOCK;
    mysqldump --all-databases --master-data -p"password" > mysql_master.dmp)
    UNLOCK TABLES;

`--master-data`  automatically appends the `CHANGE MASTER TO` statement required on the slave to start the replication process


## Slave Node step by step

### 1. Install mysql server

 - install mysql-server (yum install mysql-server)
 - set a password for mysql root user: /usr/bin/mysqladmin -u root password "password"
 - configure firewall (default port 3306)

### 2. Config /etc/my.cnf section [mysqld]

    server-id=2
    log-bin=mysql-bin
    report-host=77.77.77.112
    master-host=77.77.77.111
    master-user=repl
    master-password=password
    master-connect-retry=60
    relay-log=slave-relay-bin
    relay-log-index=slave-relay-bin.index

### 3. Restore the backup and run slave:

    SLAVE STOP;
    mysql -uroot -p"password" < mysql_master.dmp
    SLAVE START;

### 3b. Run slave:

    SLAVE STOP;
    CHANGE MASTER TO MASTER_HOST='77.77.77.111', MASTER_USER='repl', MASTER_PASSWORD='password', MASTER_PORT=3306, MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=106;
    SLAVE START;

### 4. Check Slave status:

on slave machine:
    SHOW SLAVE STATUS\G

on master machine:
    SHOW SLAVE HOSTS;

### 5. Trouble shooting:

Problem:
Last_IO_Error: Got fatal error 1236 from master when reading data from binary log
Solution:

    Slave: stop slave;

    Master: flush logs
    Master: show master status; #take note of the master log file and master log position

    Slave: CHANGE MASTER TO MASTER_LOG_FILE=’log-bin.00000X′, MASTER_LOG_POS=YYY;
    Slave: start slave;

## Bibliography:

- toplink: http://xorl.wordpress.com/2011/03/13/how-to-mysql-masterslave-replication/
- http://www.woblag.com/2012/03/setting-up-master-slave-replication-on.html
- http://www.bitbull.ch/wiki/index.php/MySQL_Replication_HowTo
- http://studioshorts.com/blog/2010/03/mysql-master-slave-replication-on-centos-rhel/
- http://techblog.zabuchy.net/2011/master-slave-replication-in-mysql-5-5/

## Tests:
- look to file: manifests/mammoth-master.pp
- create_new_database
- show databases on slave and master
- insert some data
- select data on slave and master
