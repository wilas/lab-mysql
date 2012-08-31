class mysql_cl ( $master = 'false' ) {

    #add args to mysql_cl
    #$mysql_password = "password"
    $repl_user = "repl"
    $repl_password = "password"

    #$port
    #$server_id

    package { ["mysql-server", "mysql"]:
        ensure => installed,
    }
    
    service { "mysqld":
        ensure  => running,
        enable  => true,
        require => Package["mysql-server"],
    }

    exec { "set-mysql-root-password":
        command => "mysqladmin -uroot password \"${mysql_password}\"",
        unless  => "mysqladmin -uroot -p\"${mysql_password}\" status",
        path    => ["/bin","/usr/bin"],
        require => Service["mysqld"],
    }

    if $master == 'true' { 
    # Master
        file { "/etc/my.cnf":
            ensure  => file,
            owner   => "root",
            group   => "root",
            mode    => 0644,
            content => template("mysql_cl/my.cnf.master.erb"),
            notify  => Service["mysqld"],
            require => Package["mysql-server"],
        }
        #create repl role
        exec { "create-repl-user": 
            command => "mysql -uroot -p\"${mysql_password}\" -e \"grant replication slave, replication client on *.* to '${repl_user}'@'%' identified by '$repl_password'; flush privileges;\"",
            unless  => "mysql -uroot -p\"${mysql_password}\" -e \"show grants for '${repl_user}'@'%';\"",
            path    => ["/bin","/usr/bin"],
            require => [Service["mysqld"]],
        }
        #backup database - should be read lock !
        #--master-data  automatically appends the CHANGE MASTER TO statement required on the slave to start the replication process
        exec { "backup-master":
            command   => "mysql -uroot -p\"${mysql_password}\" -e \"FLUSH TABLES WITH READ LOCK;\" && mysqldump --all-databases --master-data -p\"${mysql_password}\" > /vagrant/mysql_master.dmp && mysql -uroot -p\"${mysql_password}\" -e \"UNLOCK TABLES;\"",
            creates   => "/vagrant/mysql_master.dmp",
            path      => ["/bin","/usr/bin"],
            require   => [Service["mysqld"],Exec["create-repl-user"]],
        }
    }
    else{
     # Slave
        file { "/etc/my.cnf":
            ensure  => file,
            owner   => "root",
            group   => "root",
            mode    => 0644,
            content => template("mysql_cl/my.cnf.slave.erb"),
            notify  => Service["mysqld"],
            require => Package["mysql-server"],
        }
        #restore database - add unless or other more convinient solution, not create file...
        exec { "restore-slave":
            command     => "mysql -uroot -p\"${mysql_password}\" -e \"stop slave;\" &&  mysql -p\"${mysql_password}\" < /vagrant/mysql_master.dmp && mysql -uroot -p\"${mysql_password}\" -e \"start slave;\" && touch /vagrant/mysql_slave.done",
            creates   => "/vagrant/mysql_slave.done",
            path        => ["/bin","/usr/bin"],
            require     => [Service["mysqld"]],
        }
    }

    #backup data
    #mysqldump --all-databases --master-data -p$mysql_password > example_db.dmp

    #restore data
    #mysql -p < /vagrant/example_db.dmp

    #tests:
    #On Master
    #SHOW MASTER STATUS;
    #SHOW SLAVE HOSTS;
    #On Slave
    #SHOW SLAVE STATUS\G

    #manage slave:
    #stop slave;
    #CHANGE MASTER TO  MASTER_HOST='77.77.77.111',  MASTER_USER='repl',  MASTER_PASSWORD='password',  MASTER_LOG_FILE='mysql-bin.000005',  MASTER_LOG_POS=413;
    #start slave;

}
