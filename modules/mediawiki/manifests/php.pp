# mediawiki::php
class mediawiki::php {
    $packages = [
        'php',
        'php-curl',
        'php-fpm',
        'php-gd',
        'php-intl',
        'php-json',
        'php-imagick',
        'php-pear',
        'php-mail',
        'php-mcrypt',
        'php-mbstring',
        'php-mysql',
        'php-redis',
    ]

    package { $packages:
        ensure => present,
    }

    if os_version('ubuntu == xenial') {
        service { 'php7.0-fpm':
            ensure  => running,
            require => Package['php7.0-fpm'],
        }

        file { '/etc/php/7.0/fpm/php-fpm.conf':
            ensure => 'present',
            mode   => '0755',
            source => 'puppet:///modules/mediawiki/php/php-fpm7.0.conf',
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
    } else {
        service { 'php7.1-fpm':
            ensure  => running,
            require => Package['php7.1-fpm'],
        }

        file { '/etc/php/7.1/fpm/php-fpm.conf':
            ensure => 'present',
            mode   => '0755',
            source => 'puppet:///modules/mediawiki/php/php-fpm7.0.conf',
            notify => Service['php7.1-fpm'],
        }

        file { '/etc/php/7.1/fpm/pool.d/www.conf':
            ensure => 'present',
            mode   => '0755',
            source => 'puppet:///modules/mediawiki/php/www.conf',
            notify => Service['php7.1-fpm'],
        }

        file { '/etc/php/7.1/fpm/php.ini':
            ensure => present,
            mode   => '0755',
            source => 'puppet:///modules/mediawiki/php/php.ini',
            notify => Service['php7.1-fpm'],
        }
    }
}
