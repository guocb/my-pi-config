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

	# spin down disks when idle
	$disks = ['/dev/sda', '/dev/sdb']
	package {["hdparm"]: }
	file { "/etc/hdparm.conf":
		content => template("nas/hdparm.conf.erb"),
	}
	service { "hdparm":
		require => Package['hdparm'],
		subscribe => File['/etc/hdparm.conf']
	}

    # mount usb disks
    file {['/mnt/new', '/mnt/old', '/mnt/old/c', '/mnt/old/d', '/mnt/old/e', '/mnt/old/f',
            '/mnt/old/g', '/mnt/old/h']:
        ensure => directory,
    }
    file {'/etc/fstab':
        source => 'puppet:///modules/nas/fstab'
    }
}
