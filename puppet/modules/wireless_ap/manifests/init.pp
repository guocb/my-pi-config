class wireless_ap {
	$ssid = extlookup('wireless_ap_ssid')
	$passphrase = extlookup('wireless_ap_pass')

    package { ["hostapd", "dnsmasq"]: }
	file { "hostapd.conf":
		path => '/etc/hostapd/hostapd.conf',
		content => template('wireless_ap/hostapd.conf.erb')
	}
    service { "hostapd":
		require => Package['hostapd'],
		subscribe => File['hostapd.conf']
	}

	$dhcp_start = extlookup('dhcp_start', '192.168.1.100')
	$dhcp_end = extlookup('dhcp_end', '192.168.1.200')
	$dhcp_expir = extlookup('dhcp_expir', '12h')
	file {'dnsmasq.conf':
		path => '/etc/dnsmasq.conf',
		content => template('wireless_ap/dnsmasq.conf.erb')
	}
	file {'dnsmasq.default':
		path => '/etc/default/dnsmasq',
		source => 'puppet:///modules/wireless_ap/dnsmasq.default'
	}
    service { "dnsmasq":
		require => Package['dnsmasq'],
		subscribe => File['dnsmasq.conf', 'dnsmasq.default']
	}

	# dhcpcd
	file {'dhcpcd.conf':
		path => '/etc/dhcpcd.conf',
		source => 'puppet:///modules/wireless_ap/dhcpcd.conf'
	}
	service { 'dhcpcd':
		subscribe => File['dhcpcd.conf']
	}
	# ipv4 forwarding
	exec {'ipv4_forward':
		command => 'sysctl -w net.ipv4.ip_forward=1',
		path => ['/sbin', '/bin'],
		onlyif => 'sysctl net.ipv4.ip_forward|grep "= 0"',
	}
	file {'iptables_rules':
		path => '/etc/iptables.ipv4.nat',
		source => 'puppet:///modules/wireless_ap/iptables.ipv4.nat'
	}
	cron {'restore_iptables':
		command => 'iptables-restore < /etc/iptables.ipv4.nat',
		special => 'reboot',
		user => 'root',
	}
}
