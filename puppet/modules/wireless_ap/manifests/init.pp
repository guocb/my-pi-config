class wireless_ap {
    package { ["hostapd", "dnsmasq"]: }
    service { "hostapd": }
    service { "dnsmasq": }
}
