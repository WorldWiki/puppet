# class: mediawiki::dumps
#
# Cron jobs of select wiki dumps
class mediawiki::dumps {
    package { 'zip':
        ensure => present,
    }

    cron { 'Export xml dump monthly':
        ensure   => present,
        command  => '/usr/bin/nice -n19 /usr/bin/php /srv/mediawiki/w/maintenance/dumpBackup.php --logs --full --uploads > /mnt/mediawiki-static/dumps/amaninfowiki.xml',
        user     => 'www-data',
        minute   => '0',
        hour     => '0',
        month    => '*',
        monthday => ['15', '30'],
    }
