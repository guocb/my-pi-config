$extlookup_datadir = "/home/pi/"
$extlookup_precedence = ["%{fqdn}", "domain_%{domain}", "common", "pi-config"]

node default {
    include nas
    include wireless_ap
    include downloader
    package { ["git", "puppet"]: }
}

