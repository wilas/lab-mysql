class mysql_cl {

    $master = hiera('mysql_cl::is_master',false)
    $mysql_password = hiera('mysql_cl::mysql_password','password')
    $repl_user = hiera('mysql_cl::repl_user','repl')
    $repl_password = hiera('mysql_cl::repl_password','password')
    $port = hiera('mysql_cl::mysql_port',3306)
    $server_id = hiera('mysql_cl::server_id',1)

    package { ['mysql-server', 'mysql']:
        ensure => installed,
    }

    service { 'mysqld':
        ensure  => running,
        enable  => true,
        require => Package['mysql-server'],
    }

    exec { 'set-mysql-root-password':
        command => "mysqladmin -uroot password \"${mysql_password}\"",
        unless  => "mysqladmin -uroot -p\"${mysql_password}\" status",
        path    => '/bin:/usr/bin',
        require => Service['mysqld'],
    }

    if $master == true {
        # Master
        # conf file
        file { '/etc/my.cnf':
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => template('mysql_cl/my.cnf.master.erb'),
            notify  => Service['mysqld'],
            require => Package['mysql-server'],
        }
        # create repl role
        exec { 'create-repl-user':
            command => "mysql -uroot -p\"${mysql_password}\" -e \"grant replication slave, replication client on *.* to '${repl_user}'@'%' identified by '${repl_password}'; flush privileges;\"",
            unless  => "mysql -uroot -p\"${mysql_password}\" -e \"show grants for '${repl_user}'@'%';\"",
            path    => '/bin:/usr/bin',
            require => Service['mysqld'],
        }
        # backup database - db must be with read lock!
        # --master-data automatically appends the CHANGE MASTER TO statement required on the slave to start the replication process
        exec { 'backup-master':
            command => "mysql -uroot -p\"${mysql_password}\" -e \"FLUSH TABLES WITH READ LOCK;\" && mysqldump --all-databases --master-data -p\"${mysql_password}\" > /vagrant/mysql_master.dmp && mysql -uroot -p\"${mysql_password}\" -e \"UNLOCK TABLES;\"",
            creates => '/vagrant/mysql_master.dmp',
            path    => '/bin:/usr/bin',
            require => [Service['mysqld'],Exec['create-repl-user']],
        }
    }
    else{
        # Slave
        # get master host name
        $master_host = hiera('mysql_cl::master_host',undef)
        if $master_host {
            # conf file
            file { '/etc/my.cnf':
                ensure  => file,
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template('mysql_cl/my.cnf.slave.erb'),
                notify  => Service['mysqld'],
                require => Package['mysql-server'],
            }
            # restore database - add unless or other more convinient solution, not create file...
            exec { 'restore-slave':
                command => "mysql -uroot -p\"${mysql_password}\" -e \"stop slave;\" &&  mysql -p\"${mysql_password}\" < /vagrant/mysql_master.dmp && mysql -uroot -p\"${mysql_password}\" -e \"start slave;\" && touch /vagrant/mysql_slave.done",
                creates => '/vagrant/mysql_slave.done',
                path    => '/bin:/usr/bin',
                require => Service['mysqld'],
            }
        }
    }
}
