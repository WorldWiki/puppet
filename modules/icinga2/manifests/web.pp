# = Class: icinga2::web
#
# Sets up an apache instance for icinga web interface,
# protected with ldap authentication
class icinga2::web(
    $icingaweb_db_host = hiera('icingaweb_db_host'),
    $icingaweb_db_name = hiera('icingaweb_db_name'),
    $icingaweb_user_name = hiera('icingaweb_user_name'),
    $icingaweb_password = hiera('icingaweb_password'),
    $icinga_ido_db_host = hiera('icinga_ido_db_host'),
    $icinga_ido_db_name = hiera('icinga_ido_db_name'),
    $icinga_ido_user_name = hiera('icinga_ido_user_name'),
    $icinga_ido_password = hiera('icinga_ido_password'),
    $director_db_host = hiera('director_db_host'),
    $director_db_name = hiera('director_db_name'),
    $director_user_name = hiera('director_user_name'),
    $director_password = hiera('director_password'),
    $icinga_api_password = hiera('icinga_api_password'),
) {
    include ::icinga2

    package { [ 'icingaweb2', 'icingaweb2-module-monitoring',
                'icingaweb2-module-doc', 'icingacli' ] :
        ensure => present,
        require => Apt::Repository['icinga2'],
    }

    include ::apache

    if os_version('debian == jessie') {
        include ::apache::mod::php5
    } elsif os_version('debian >= stretch') {
        include ::apache::mod::php7
    } elsif os_version('ubuntu >= artful') {
        include ::apache::mod::php71
    }

    include ::apache::mod::ssl
    include ::apache::mod::headers
    include ::apache::mod::cgi

    # TODO fix compatiblity to so other classes doin't throw duplicate's puppet error
    #if os_version('ubuntu >= artful || debian >= stretch') {
    #    package { [ 'php', 'php-dev', 'php-curl', 'php-imagick',
    #                'php-gd', 'php-json', 'php-mbstring', 'php-common',
    #                'php-mysql', 'php-ldap' ] :
    #        ensure => 'installed',
    #    }
    #} else {
    #    package { [ 'php5', 'php5-dev', 'php5-curl', 'php5-imagick',
    #                'php5-gd', 'php5-json', 'php5-mbstring', 'php5-common',
    #                'php5-mysql', 'php5-ldap' ] :
    #        ensure => 'installed',
    #    }
    #}

    file { '/etc/icingaweb2':
        ensure => 'directory',
        owner  => 'www-data',
        group  => 'icingaweb2',
        mode   => '2755',
    }

    file { '/etc/icingaweb2/authentication.ini':
        ensure => present,
        content => template('icinga2/authentication.ini.erb'),
        owner  => 'www-data',
        group  => 'icingaweb2',
    }

    file { '/etc/icingaweb2/groups.ini':
        ensure => present,
        content => template('icinga2/groups.ini.erb'),
        owner  => 'www-data',
        group  => 'icingaweb2',
    }

    file { '/etc/icingaweb2/resources.ini':
        ensure => present,
        content => template('icinga2/resources.ini.erb'),
        owner  => 'www-data',
        group  => 'icingaweb2',
    }

    file { '/etc/icingaweb2/modules/director':
        ensure => 'directory',
        owner  => 'www-data',
        group  => 'icingaweb2',
    }

    file { '/etc/icingaweb2/modules/director/config.ini':
        ensure => present,
        content => template('icinga2/config.ini.erb'),
        owner  => 'www-data',
        group  => 'icingaweb2',
        require => File['/etc/icingaweb2/modules/director'],
    }

    file { '/etc/icingaweb2/modules/director/kickstart.ini':
        ensure => present,
        content => template('icinga2/kickstart.ini.erb'),
        owner  => 'www-data',
        group  => 'icingaweb2',
        require => File['/etc/icingaweb2/modules/director'],
    }

    file { '/etc/icingaweb2/modules/monitoring/backends.ini':
        ensure => present,
        content => template('icinga2/backends.ini.erb'),
        owner  => 'www-data',
        group  => 'icingaweb2',
    }

    file { '/etc/icingaweb2/modules/monitoring/commandtransports.ini':
        ensure => present,
        content => template('icinga2/commandtransports.ini.erb'),
        owner  => 'www-data',
        group  => 'icingaweb2',
    }

    #file { '/etc/icingaweb2/modules/monitoring/roles.ini':
    #    ensure => present,
    #    content => template('icinga2/roles.ini.erb'),
    #    owner  => 'www-data',
    #    group  => 'icingaweb2',
    #}

    #git::clone { 'beta-mediawiki-core':
    #    directory => "${stage_dir}/php-master",
    #    origin    => 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
    #    branch    => 'master',
    #    owner     => 'root',
    #    group     => 'root',
    #    require   => Package['icingaweb2'],
    #}

    # install the Icinga Apache site
    include ::apache::mod::rewrite
    include ::apache::mod::authnz_ldap
    include ::apache::mod::rewrite

    include ::apache::mod::proxy

    include ::apache::mod::proxy_http

    include ::apache::mod::headers


    #letsencrypt::cert::integrated { 'gerrit-icinga':
    #     subjects   => 'gerrit-icinga.wmflabs.org',
    #     puppet_svc => 'apache2',
    #     system_svc => 'apache2',
    #}

    $ssl_settings = ssl_ciphersuite('apache', 'mid', true)
    # letsencrypt::cert::integrated { 'icinga2':
    #    subjects   => hiera('icinga2_apache_host', 'icinga.wmflabs.org'),
    #    puppet_svc => 'apache2',
    #    system_svc => 'apache2',
    #    require    => Class['apache::mod::ssl'],
    #}

    apache::site { 'icinga.wiki.org.uk':
        content => template('icinga2/icinga.wiki.org.uk.erb'),
    }
}
