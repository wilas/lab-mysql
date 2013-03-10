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
host { $fqdn:
    ip           => $ipaddress_eth1,
    host_aliases => $hostname,
}
host { 'mammoth01.farm':
    ip           => '77.77.77.111',
    host_aliases => 'mammoth01',
}
