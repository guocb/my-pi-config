class downloader {
    $username = extlookup('transmission-username')
    $password = extlookup('transmission-password')
    $ip_list = ['192.168.*.*', '127.0.0.1']

    package {['transmission-common', 'transmission-daemon']: }
    file { 'transmission-settings':
        path => '/etc/transmission-daemon/settings.json',
        content => template('downloader/transmission-settings.json.erb'),
    }
    service {'transmission-daemon':
        ensure => running,
        require => Package['transmission-common', 'transmission-daemon'],
        subscribe => File['transmission-settings'],
    }
}
