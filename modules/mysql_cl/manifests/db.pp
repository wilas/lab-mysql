define mysql_cl::db( $user, $password ) {
    include mysql_cl
    exec { "create-${name}-db":
        command => "mysql -uroot -p\"${mysql_password}\" -e \"create database ${name};\"",
        unless => "mysql -u${user} -p\"${password}\" ${name}",
        path    => ["/bin","/usr/bin"],
        require => Service["mysqld"],
    }

    exec { "grant-${name}-db":
        command => "mysql -uroot -p\"${mysql_password}\" -e \"grant all on ${name}.* to ${user}@localhost identified by '$password'; flush privileges;\"",
        unless  => "mysql -u${user} -p\"${password}\" ${name}",
        path    => ["/bin","/usr/bin"],
        require => [Service["mysqld"], Exec["create-${name}-db"]]
    }
}

