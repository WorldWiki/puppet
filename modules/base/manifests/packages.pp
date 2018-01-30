# class: base::packages
class base::packages {
    $packages = [
        'acct',
        'apt-transport-https',
        'atop',
        'coreutils',
        'debian-goodies',
        'git',
        'htop',
        'logrotate',
        'mtr',
        'nano',
		'curl',
        'pigz',
        'screen',
        'strace',
        'tcpdump',
        'vim',
        'wipe',
    ]

    package { $packages:
        ensure => present,
    }

    # Get rid of this
    package { [ 'apt-listchanges' ]:
        ensure => absent,
    }
}
