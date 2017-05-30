class wireless_ap {
	$ssid = extlookup('wireless_ap_ssid')
	$passphrase = extlookup('wireless_ap_pass')

    package { ["hostapd", "dnsmasq"]: }
	file { "hostapd.conf":
		path => '/etc/hostapd/hostapd.conf',
		content => template('wireless_ap/hostapd.conf.erb')
	}
    service { "hostapd":
        ensure => running,
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
    file {'hostapd.default':
        path => '/etc/default/hostapd',
        source => 'puppet:///modules/wireless_ap/hostapd.default'
    }
    service { "dnsmasq":
        ensure => running,
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
    file {
        'wlan0':
                path => '/etc/network/interfaces.d/wlan0',
                source => 'puppet:///modules/wireless_ap/wlan0';
        'interfaces':
                path => '/etc/network/interfaces',
                source => 'puppet:///modules/wireless_ap/interfaces';
    }
    service {'networking':
        subscribe => File['wlan0', 'interfaces'],
    }
	# ipv4 forwarding
	exec {'ipv4_forward':
		command => 'sysctl -w net.ipv4.ip_forward=1',
		path => ['/sbin', '/bin'],
		onlyif => 'test `cat /proc/sys/net/ipv4/ip_forward` -eq 0',
	}
	file {'iptables_rules':
		path => '/etc/iptables.ipv4.nat',
		source => 'puppet:///modules/wireless_ap/iptables.ipv4.nat'
	}
    exec { 'add ip forward to config':
        command => 'echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf',
	path => ['/sbin', '/bin'],
	unless => 'grep -q "net.ipv4.ip_forward = 1" /etc/sysctl.conf',
    }
    file { '/etc/network/if-up.d/firewall':
        mode => 0755,
        owner => root,
        group => root,
        content => "#!/usr/bin/env bash\niptables-restore < /etc/iptables.ipv4.nat\n",
    }
}
