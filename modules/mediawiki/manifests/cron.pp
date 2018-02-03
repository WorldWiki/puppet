# class: mediawiki::cron
#
# Used for CORE crons which should be ran on every MediaWiki server.
class mediawiki::cron {
    cron { 'update.php for LocalisationUpdate':
        ensure  => present,
        command => '/usr/bin/php /srv/mediawiki/w/extensions/LocalisationUpdate/update.php > /var/log/mediawiki/debuglogs/l10nupdate.log',
        user    => 'www-data',
        minute  => '5',
        hour    => '23',
    }
    cron { 'Tor exit node loading':
        ensure  => present,
        command => '/usr/bin/php /srv/mediawiki/w/extensions/TorBlock/loadExitNodes.php > /var/log/mediawiki/debuglogs/torblockload.log',
        user    => 'www-data',
        minute  => '10',
        hour    => '23',
    }
    cron { 'AntiSpoof':
        ensure  => present,
        command => '/usr/bin/php /srv/mediawiki/w/extensions/AntiSpoof/maintenance/batchAntiSpoof.php > /var/log/mediawiki/debuglogs/antispoof.log',
        user    => 'www-data',
        minute  => '15',
        hour    => '23',
    }
    cron { 'restart_php5fpm':
        ensure  => absent,
        command => '/usr/sbin/service php7.0-fpm restart',
        minute  => '*/10',
    }
}
