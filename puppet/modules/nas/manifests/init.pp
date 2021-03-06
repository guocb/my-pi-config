class nas {
    package { ["samba", "samba-common-bin", "ntfs-3g"]: }
    $samba_user = "nas"
    $samba_pass = extlookup('samba_pass')
    user { $samba_user:
        shell => '/usr/sbin/nologin',
        comment => 'account for nas samba access only',
        #password => "$samba_pass",
    }
    exec { "add smb account for ${samba_user}":
        command => "/bin/echo -e '${sama_pass}\\n${samba_pass}\\n' | /usr/bin/pdbedit --password-from-stdin -a '${samba_user}'",
        unless  => "/usr/bin/pdbedit '${samba_user}'",
        require => [ User[$samba_user] ],
    }
    file { "samba.conf":
        path => "/etc/samba/smb.conf",
        content => template('nas/samba.conf.erb'),
    }

    service { "smbd":
        ensure => running,
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
