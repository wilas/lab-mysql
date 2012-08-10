# Description:
 - OS: Scientific linux 6
 - mysql master-slave cluster

# I Master Node

## 1. Install mysql server
 - install mysql-server (yum install mysql-server)
 - set a password for mysql root user: /usr/bin/mysqladmin -u root password password
 - firewall !!
## 2. Configure mysql master (vim /etc/my.cnf, section [mysqld]):
  log-bin = mysql-bin
  server-id = 1
  #binlog-do-db=example_d
 and restart mysql master (/etc/init.d/mysqld restart)
## 3. Create Slave user and check Master status
 - grant replication slave, replication client on *.* to 'repl'@'%' identified by 'password';
 - FLUSH PRIVILEGES;
 - #here you can create db, for example exaple_db look on: /vagrant/test.sql
 - FLUSH TABLES WITH READ LOCK;
 - SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000002 |      106 | example_db   |                  |
+------------------+----------+--------------+------------------+

## 4. Backup database and transfer to slave and restore
 -mysqldump (mysqldump -u root -p mydbname > mydbname.dump) (mysqldump --all-databases --master-data -p > example_db.dmp)
 -innobackupex --defaults-file=/etc/my.cnf --user=***** --password=***** --databases=mydbname /path/to/backup/
 -transfer: scp, cp_to_nfs... (scp –r /path/to/backup/ user@server:/path/to/slave/destination)
## 5. Unlock db:
 - UNLOCK TABLES;

# II Slave Node
## 1. Install mysql server
 - yum install mysql-server
 - mysqladmin -u root password password
 - firewall !!
## 2. Restore the backup
 - mysql_restore: mysql -u **** -p **** < mydbname.dump (mysql < example_db.dmp)
 - innobackupex --apply-log --user=****** --password=****** /path /to/slave/destination
## 3. Config /etc/my.cnf section [mysqld]
 server-id=2
 report-host=77.77.77.152
 master-host=77.77.77.151
 master-user=repl
 master-password=password
 master-connect-retry=60
 #Specify database to replicate
 replicate-wild-do-table=example_db.%
## 4. run and check:
 SLAVE STOP;
 CHANGE MASTER TO MASTER_HOST='77.77.77.151', MASTER_USER='repl', MASTER_PASSWORD='password', MASTER_PORT=3306, MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=106;
 START SLAVE;
 SHOW SLAVE STATUS\G
5. Trouble shooting:
 Last_IO_Error: Got fatal error 1236 from master when reading data from binary log
 Solution:
 Slave: stop slave;

 Master: flush logs
 Master: show master status; — take note of the master log file and master log position

 Slave: CHANGE MASTER TO MASTER_LOG_FILE=’log-bin.00000X′, MASTER_LOG_POS=106;
 Slave: start slave;

## Bibliography:
- toplink: http://xorl.wordpress.com/2011/03/13/how-to-mysql-masterslave-replication/
- http://www.woblag.com/2012/03/setting-up-master-slave-replication-on.html
- http://www.bitbull.ch/wiki/index.php/MySQL_Replication_HowTo
- http://studioshorts.com/blog/2010/03/mysql-master-slave-replication-on-centos-rhel/
- http://techblog.zabuchy.net/2011/master-slave-replication-in-mysql-5-5/

# Rsyslog Zone:
## 1. Install
 - yum install rsyslog (installed by default)
 - chkconfig rsyslog on
## 2. Configure central logging server (ip=77.77.77.161):
 Provides UDP syslog reception
 $ModLoad imudp
 $UDPServerRun 514
 This one is the template to generate the log filename dynamically, depending on the client's Hostname.
 $template FILENAME,"/var/log/%HOSTNAME%/%syslogtag%
 Log all messages to the dynamically formed file. Now each clients log (192.168.1.2, 192.168.1.3,etc...), will be under a separate directory which is formed by the template FILENAME.
 *.* ?FILENAME

## 3. Configure client
 add line:
 $WorkDirectory /var/lib/rsyslog # where to place spool files
 $ActionQueueFileName fwdRule1 # unique name prefix for spool files
 $ActionQueueMaxDiskSpace 1g   # 1gb space limit (use as much as possible)
 $ActionQueueSaveOnShutdown on # save messages to disk on shutdown
 $ActionQueueType LinkedList   # run asynchronously
 $ActionResumeRetryCount -1
 *.* @77.77.77.161:514
## 4. Move logs:
 change from:
 Log all the mail messages in one place.
 mail.*                                                -/var/log/maillo 
 to:
 Log all the mail messages in one place.
 mail.*  @77.77.77.161                                                -/var/log/maillo 
## 5. Template !!!
 - more and more ! 
## Bibliography
 - http://www.thegeekstuff.com/2012/01/rsyslog-remote-logging/
 - http://jerrylparker.com/?p=21
 - http://docs.fedoraproject.org/en-US/Fedora/15/html/Deployment_Guide/ch-Viewing_and_Managing_Log_Files.html

# Graylog2 Zone
## 1. Install
 - http://frednotes.wordpress.com/2012/01/06/graylog2-on-centos-6-2-easy-visual-log-parsing/
 - template for rsyslog-graylog2: https://github.com/Graylog2/graylog2-server/wiki/Forwarding-from-rsyslog

# XX  Fluentd Zone:
## 1a. Install using gem:
 - yum install 'zlib-devel'
 - install rvm: curl -L https://get.rvm.io | bash -s stable --ruby
 - source /usr/local/rvm/scripts/rvm
 - vim .bashrc
 - now we have ruby 1.9.3 -> rvm --create use 1.9.3@arena default
 - gem install fluentd
## 1b. !! Install using repo (recommended)
 - vim /etc/yum.repos.d/td.repo
 [treasuredata]
 name=TreasureData
 baseurl=http://packages.treasure-data.com/redhat/$basearch
 gpgcheck=0
 -yum repolist
 -yum install td-agent
## 2. start agent
 -/etc/init.d/td-agent start
## 3a. config agent (center) - vim /etc/td-agent/td-agent.conf
 -
## 3b. config agent (client) - vim /etc/td-agent/td-agent.conf
 -
## 4. restart agent
 -/etc/init.d/td-agent restart
## 5. Bibliography
 - http://fluentd.org/doc/plugin.html#input-plugin
 - http://help.treasure-data.com/kb/installing-td-agent-daemon/installing-td-agent-for-redhat-and-centos
