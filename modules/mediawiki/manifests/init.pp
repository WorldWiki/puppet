# class: mediawiki
class mediawiki(
    $branch = undef,
) {
    include mediawiki::favicons
    include mediawiki::cron
    include mediawiki::nginx
    include mediawiki::php
    include mediawiki::wikistats

    if hiera(jobrunner) {
        include mediawiki::jobrunner
    }
    if hiera(mwdumps) {
        include mediawiki::dumps
    }

    file { [ 
        '/srv/mediawiki', 
        '/srv/mediawiki/cdb-config', 
        '/var/log/mediawiki', 
        '/var/log/mediawiki/debuglogs' 
    ]:
        ensure => 'directory',
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0755',
    }

    file { '/etc/nginx/nginx.conf':
        content => template('mediawiki/nginx.conf.erb'),
        require => Package['nginx'],
    }

    file { '/etc/nginx/fastcgi_params':
        ensure => present,
        source => 'puppet:///modules/mediawiki/nginx/fastcgi_params',
    }

    file { '/etc/nginx/sites-enabled/default':
        ensure => absent,
    }

    $packages = [
        'djvulibre-bin',
        'dvipng',
        'htmldoc',
        'imagemagick',
        'ploticus',
        'ttf-freefont',
        'ffmpeg2theora',
        'locales-all',
        'oggvideotools',
        'libav-tools',
        'libvips-tools',
        'lilypond',
        'poppler-utils',
        'python-pip',
    ]

    package { $packages:
        ensure => present,
    }

    package { [ 'texvc', 'ocaml' ]:
        ensure          => present,
        install_options => ['--no-install-recommends'],
    }

    file { '/etc/ImageMagick-6/policy.xml':
        ensure  => present,
        source  => 'puppet:///modules/mediawiki/imagemagick/policy.xml',
        require => Package['imagemagick'],
    }

    nginx::conf { 'mediawiki-includes':
        ensure => present,
        source => 'puppet:///modules/mediawiki/nginx/mediawiki-includes.conf',
    }

    git::clone { 'Landing Page':
        ensure             => 'latest',
        directory          => '/srv/mediawiki/landing',
        origin             => 'https://github.com/WorldWiki/Landing-page',
        branch             => 'master',
        owner              => 'www-data',
        group              => 'www-data',
        mode               => '0755',
        timeout            => '550',
        recurse_submodules => true,
        require            => File['/srv/mediawiki'],
    }

    git::clone { 'MediaWiki config':
        ensure    => 'latest',
        directory => '/srv/mediawiki/config',
        origin    => 'https://github.com/WorldWiki/mediawiki-config',
        owner     => 'www-data',
        group     => 'www-data',
        mode      => '0755',
        require   => File['/srv/mediawiki'],
    }

    git::clone { 'MediaWiki core':
        ensure             => 'latest',
        directory          => '/srv/mediawiki/w',
        origin             => 'https://github.com/WorldWiki/mediawiki',
        branch             => $branch,
        owner              => 'www-data',
        group              => 'www-data',
        mode               => '0755',
        timeout            => '550',
        recurse_submodules => true,
        require            => File['/srv/mediawiki'],
        before             => File['/srv/mediawiki/w'],
    }

    file { '/srv/mediawiki/w':
        ensure => 'directory',
        owner   => 'www-data',
        group   => 'www-data',
    }

    file { '/srv/mediawiki/robots.txt':
        ensure  => 'present',
        source  => 'puppet:///modules/mediawiki/robots.txt',
        require => File['/srv/mediawiki'],
    }

    file { '/srv/mediawiki/w/LocalSettings.php':
        ensure  => 'link',
        target  => '/srv/mediawiki/config/LocalSettings.php',
        owner   => 'www-data',
        group   => 'www-data',
        require => Git::Clone['MediaWiki config'],
    }
    
    file { '/var/log/php7.0-fpm.log':
        ensure  => 'present',
        owner   => 'www-data',
        group   => 'www-data',
        mode    => '0755',
    }

    $wikiadmin_password   = hiera('passwords::db::wikiadmin', 'test')
    $mediawiki_dbname     = hiera('passwords::db::mediawiki::dbname', 'test')
    $mediawiki_user       = hiera('passwords::db::mediawiki::dbuser', 'test')
    $mediawiki_password   = hiera('passwords::db::mediawiki::password', 'test')
    $redis_password       = hiera('passwords::redis::master', 'test')
    $noreply_password     = hiera('passwords::mail::noreply', 'test')
    $mediawiki_upgradekey = hiera('passwords::mediawiki::upgradekey', 'test')
    $mediawiki_secretkey  = hiera('passwords::mediawiki::secretkey', 'test')
    $recaptcha_sitekey    = hiera('passwords::recaptcha::sitekey', 'test')
    $recaptcha_secretkey  = hiera('passwords::recaptcha::secretkey', 'test')
    $googlemaps_key       = hiera('passwords::mediawiki::googlemapskey', 'test')

    file { '/srv/mediawiki/config/PrivateSettings.php':
        ensure  => 'present',
        content => template('mediawiki/PrivateSettings.php'),
        require => Git::Clone['MediaWiki config'],
    }

    file { '/usr/local/bin/foreachwikiindblist':
        ensure => 'present',
        mode   => '0755',
        source => 'puppet:///modules/mediawiki/bin/foreachwikiindblist',
    }

    logrotate::rotate { 'mediawiki_wikilogs':
        logs   => '/var/log/mediawiki/*.log',
        rotate => '6',
        delay  => false,
    }

    logrotate::rotate { 'mediawiki_debuglogs':
        logs   => '/var/log/mediawiki/debuglogs/*.log',
        rotate => '6',
        delay  => false,
    }

    #exec { 'curl -sS https://getcomposer.org/installer | php && php composer.phar install':
    #    creates     => '/srv/composer.phar',
    #    cwd         => '/srv',
    #    path        => '/usr/bin',
    #    environment => 'HOME=/srv',
    #    user        => 'www-data',
    #    require     => Git::Clone['MediaWiki core'],
    #}

    #exec { 'ExtensionMessageFiles':
    #    command     => 'php /srv/mediawiki/w/maintenance/mergeMessageFileList.php --wiki loginwiki --output /srv/mediawiki/config/ExtensionMessageFiles.php',
    #    creates     => '/srv/mediawiki/config/ExtensionMessageFiles.php',
    #    cwd         => '/srv/mediawiki/config',
    #    path        => '/usr/bin',
    #    environment => 'HOME=/srv/mediawiki/config',
    #    user        => 'www-data',
    #    require     => Git::Clone['MediaWiki core'],
    #}
    
    #icinga::service { 'mediawiki_rendering':
    #    description   => 'MediaWiki Rendering',
    #    check_command => 'check_mediawiki!meta.miraheze.org',
    #}

    #icinga::service { 'php5-fpm':
    #    description   => 'php5-fpm',
    #    check_command => 'check_nrpe_1arg!check_php_fpm',
    #}
}
