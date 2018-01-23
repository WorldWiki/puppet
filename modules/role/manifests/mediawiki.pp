# role: mediawiki
class role::mediawiki {
    include ::mediawiki

    motd::role { 'role::mediawiki':
        description => 'MediaWiki server',
    }

    file { '/mnt/mediawiki-static':
        ensure => directory,
    }

    mount { '/mnt/mediawiki-static':
        ensure  => mounted,
        device  => '81.4.124.61:/srv/mediawiki-static',
        fstype  => 'nfs',
        options => 'rw',
        atboot  => true,
        require => File['/mnt/mediawiki-static'],
    }
}
