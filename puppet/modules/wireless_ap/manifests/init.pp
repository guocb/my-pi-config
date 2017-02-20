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
		source => 'puppet:///wireless_ap/dnsmasq.default'
	}
    service { "dnsmasq":
		require => Package['dnsmasq'],
		subscribe => File['dnsmasq.conf', 'dnsmasq.default']
	}
}
