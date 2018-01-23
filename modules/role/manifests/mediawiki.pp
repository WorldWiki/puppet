# role: mediawiki
class role::mediawiki {
    include ::mediawiki

    motd::role { 'role::mediawiki':
        description => 'MediaWiki server',
    }

    file { '/srv/mediawiki-static':
        ensure => directory,
    }
}
