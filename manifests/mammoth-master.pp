stage { "base": before => Stage["main"] }
stage { "tuning": before => Stage["main"] }
stage { "last": require => Stage["main"] }

#basic
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base"}

#hosts:
host { "$fqdn":
    ip          => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

host { "mammoth02.farm":
    ip          => "77.77.77.112",
    host_aliases => "mammoth02",
}

#firewall manage
service { "iptables":
    ensure => running,
    enable => true,
}
exec { 'clear-firewall':
    command => '/sbin/iptables -F',
    refreshonly => true,        
}
exec { 'persist-firewall':
    command => '/sbin/iptables-save >/etc/sysconfig/iptables',
    refreshonly => true,
}
Firewall {
    subscribe => Exec['clear-firewall'],
    notify => Exec['persist-firewall'],
}
class { "basic_firewall": }

$mysql_password="password"
class { "mysql_cl": 
    master => 'true',
}
firewall { '100 allow mysql':
    state  => ['NEW'],
    dport  => '3306',
    proto  => 'tcp',
    action => accept,
}

#TEST ZONE - uncomment for tests:
mysql_cl::db { "testme":
    user     => "testme",
    password => "password",
}
#create table and insert some data
exec { 'insert data into testme':
    command     => "mysql -uroot -p\"${mysql_password}\" testme < /vagrant/tools/testme.sql",
    path        => "/bin:/sbin:/usr/bin:/usr/sbin",
    subscribe   => Mysql_cl::Db["testme"],
    refreshonly => true,
}

