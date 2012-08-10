class mysql_cl {

    #add args to mysql_cl

    package { ["mysql-server", "mysql"]:
        ensure => installed,
    }

    #Exec { "/usr/bin/mysqladmin -u root password 'password'":
    #    path =>
    #    unless =>
    #
    #}

    service { "mysqld":
        ensure => running,
        enable => true,
    }

    #master
    #file { "/etc/my.cnf": 
    #     ensure => file,
    #    template => ,
    #}

    #optional:
    #creat path for binlog

    #slave
    #file { "/etc/my.cnf":
    #     ensure => file,
    #    template => ,
    #}

}
