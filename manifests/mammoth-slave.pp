stage { "base": before  => Stage["main"] }
stage { "last": require => Stage["main"] }

class { "yum_repos": stage     => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base" }
Class["yum_repos"] -> Class["basic_package"] -> Class["user::root"]

#hosts:
host { "$fqdn":
    ip          => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

host { "mammoth01.farm":
    ip          => "77.77.77.111",
    host_aliases => "mammoth01",
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
class { "mysql_cl": }
firewall { '100 allow mysql':
    state  => ['NEW'],
    dport  => '3306',
    proto  => 'tcp',
    action => accept,
}

