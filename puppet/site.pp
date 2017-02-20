node default {
	$extlookup_datadir = "/home/pi/"
	$extlookup_precedence = ["%{fqdn}", "domain_%{domain}", "pi-config"]

    include nas
    include wireless_ap
    package { ["git", "puppet", "transmission-daemon"]: }
}

