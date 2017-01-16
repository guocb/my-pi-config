class nas {
    package { ["samba", "samba-common-bin", "ntfs-3g"]: }
    file { "samba.conf":
        path => "/etc/samba/smb.conf",
        source => "puppet:///modules/nas/samba.conf",
    }

    service { "samba":
        require => Package["samba"],
        subscribe => File["samba.conf"]
    }
}
