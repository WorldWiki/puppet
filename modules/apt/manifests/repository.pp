define apt::repository(
    $uri,
    $dist,
    $components,
    $source=true,
    $comment_old=false,
    $keyfile='',
    $ensure=present,
    $trust_repo=false,
) {
    exec { 'apt-get update':
        path        => '/usr/bin',
        timeout     => 240,
        returns     => [ 0, 100 ],
        refreshonly => true,
    }

    # Directory to hold the repository signing keys
    file { '/var/lib/apt/keys':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        recurse => true,
        purge   => true,
    }

    if $trust_repo {
        $trustedline = '[trusted=yes] '
    } else {
        $trustedline = ''
    }

    $binline = "deb ${trustedline}${uri} ${dist} ${components}\n"
    $srcline = $source ? {
        true    => "deb-src ${uri} ${dist} ${components}\n",
        default => '',
    }

    file { "/etc/apt/sources.list.d/${name}.list":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => "${binline}${srcline}",
        notify  => Exec['apt-get update'],
    }

    if $comment_old {
        $escuri = regsubst(regsubst($uri, '/', '\/', 'G'), '\.', '\.', 'G')
        $binre = "deb(-src)?\s+${escuri}\s+${dist}\s"

        # comment out the old entries in /etc/apt/sources.list
        exec { "apt-${name}-sources":
            command => "/bin/sed -ri '/${binre}/s/^deb/#deb/' /etc/apt/sources.list",
            creates => "/etc/apt/sources.list.d/${name}.list",
            before  => File["/etc/apt/sources.list.d/${name}.list"],
        }
    }

    if $keyfile and $keyfile != '' {
        file { "/var/lib/apt/keys/${name}.gpg":
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0400',
            source  => $keyfile,
            require => File['/var/lib/apt/keys'],
            before  => File["/etc/apt/sources.list.d/${name}.list"],
        }

        exec { "/usr/bin/apt-key add /var/lib/apt/keys/${name}.gpg":
            subscribe   => File["/var/lib/apt/keys/${name}.gpg"],
            refreshonly => true,
        }
    }
}
