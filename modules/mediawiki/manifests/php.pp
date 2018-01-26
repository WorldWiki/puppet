# mediawiki::php
class mediawiki::php {
    $packages = [
        'php-imagick',
        'php-pear',
        'php-mail',
        'php-mbstring',
        'php-redis',
        'php-mysqlnd',
        'php7.0',
        'php7.0-curl',
        'php7.0-fpm',
        'php7.0-gd',
        'php7.0-intl',
        'php7.0-json',
        'php7.0-mcrypt',
        'php7.0-mysql',
        'php7.0-mysqlnd',
    ]

    package { $packages:
        ensure => present,
    }

    service { 'php7.0-fpm':
        ensure  => running,
        require => Package['php7.0-fpm'],
    }

    file { '/etc/php/7.0/fpm/php-fpm.conf':
        ensure => 'present',
        mode   => '0755',
        source => 'puppet:///modules/mediawiki/php/php-fpm.conf',
        notify => Service['php7.0-fpm'],
    }

    file { '/etc/php/7.0/fpm/pool.d/www.conf':
        ensure => 'present',
        mode   => '0755',
        source => 'puppet:///modules/mediawiki/php/www.conf',
        notify => Service['php7.0-fpm'],
    }

    file { '/etc/php/7.0/fpm/php.ini':
        ensure => present,
        mode   => '0755',
        source => 'puppet:///modules/mediawiki/php/php.ini',
        notify => Service['php7.0-fpm'],
    }
}
