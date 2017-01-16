node default {
    include nas
    include wireless_ap
    package { ["git", "puppet", "transmission-daemon"]: }
}

