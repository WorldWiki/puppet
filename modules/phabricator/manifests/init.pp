# class: phabricator
class phabricator {
    include ::apache::mod::rewrite 
    include ::apache::mod::ssl
    include ::apache::mod::php71

    package { ['mariadb-server', 'mariadb-client']:
        ensure => present,
    }

    package { ['php-apcu', 'php-curl', 'php7.1-mbstring', 'php-mysql', 'python-pygments']:
        ensure => present,
    }

    apache::site { 'phabricator.wiki.org.uk':
        ensure => present,
        source => 'puppet:///modules/phabricator/phabricator.wiki.org.uk.conf',
    }

    file { '/srv/phab':
        ensure => directory,
    }

    git::clone { 'arcanist':
        ensure    => present,
        directory => '/srv/phab/arcanist',
        origin    => 'https://github.com/phacility/arcanist.git',
        require   => File['/srv/phab'],
    }

    git::clone { 'libphutil':
        ensure    => present,
        directory => '/srv/phab/libphutil',
        origin    => 'https://github.com/phacility/libphutil.git',
        require   => File['/srv/phab'],
    }

    git::clone { 'phabricator':
        ensure    => present,
        directory => '/srv/phab/phabricator',
        origin    => 'https://github.com/phacility/phabricator.git',
        require   => File['/srv/phab'],
    }

    file { '/srv/phab/repos':
        ensure => directory,
        mode   => '0755',
        owner  => 'www-data',
        group  => 'www-data',
    }

    $module_path = get_module_path($module_name)
    $phab_yaml = loadyaml("${module_path}/data/config.yaml")
    $phab_private = {
        'recaptcha.private-key'   => hiera('passwords::phabricator::recaptcha::private_key', '123'),
        'recaptcha.public-key'    => hiera('passwords::phabricator::recaptcha::public_key', '123'),
        'sendgrid.api-key'        => hiera('passwords::phabricator::sendgrid::api-key', '123'),
        'sendgrid.api-user'       => hiera('passwords::phabricator::sendgrid::api-user', 'Test'),
        'security.hmac-key'       => hiera('passwords::phabricator::security::hmac-key', '123'),
        'mysql.pass'              => hiera('passwords::db::phabricator', 'test'),
    }

    $phab_settings = merge($phab_yaml, $phab_private)

    file { '/srv/phab/phabricator/conf/local/local.json':
        ensure  => present,
        content => template('phabricator/local.json.erb'),
        notify  => Service['apache2'],
        require => Git::Clone['phabricator'],
    }

    file { '/srv/phab/images':
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
    }

    file { '/etc/php/7.1/apache2/php.ini':
        ensure => present,
        mode   => '0755',
        source => 'puppet:///modules/phabricator/php.ini',
        notify => Service['apache2'],
    }
}
