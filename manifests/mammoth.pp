# Node global
exec { 'clear-firewall':
    command     => '/sbin/iptables -F',
    refreshonly => true,
}
exec { 'persist-firewall':
    command     => '/sbin/iptables-save >/etc/sysconfig/iptables',
    refreshonly => true,
}
Firewall {
    subscribe => Exec['clear-firewall'],
    notify    => Exec['persist-firewall'],
}

# Include classes - search for classes in *.yaml/*.json files
hiera_include('classes')
# Classes order
Class['yum_repos'] -> Class['basic_package'] -> Class['user::root']
CLass['basic_package'] -> Class['mysql_cl']
# Extra firewall rules
firewall { '100 allow mysql':
    state  => ['NEW'],
    dport  => '3306',
    proto  => 'tcp',
    action => accept,
}

# In real world from DNS
host { 'mammoth01.farm':
    ip           => '77.77.77.111',
    host_aliases => 'mammoth01',
}
host { 'mammoth02.farm':
    ip           => '77.77.77.112',
    host_aliases => 'mammoth02',
}

# TEST ZONE
if $::demo_database == 'yes' {
    mysql_cl::db { 'testme':
        user     => 'testme',
        password => 'password',
    }
    # create table and insert some data
    exec { 'insert data into testme':
        command     => "mysql -uroot -p\"${mysql_cl::mysql_password}\" testme < /vagrant/tools/testme.sql",
        path        => '/bin:/sbin:/usr/bin:/usr/sbin',
        subscribe   => Mysql_cl::Db['testme'],
        refreshonly => true,
    }
}
