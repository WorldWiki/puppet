# class: phabricator
class phabricator {
    package { ['mariadb-server', 'mariadb-client']:
        ensure => present,
    }

    if ! defined(Package['php-curl']) {
        package { 'php-curl':
            ensure => present,
        }
    }

    if ! defined(Package['php-gd']) {
        package { 'php-gd':
            ensure => present,
        }
    }

    if ! defined(Package['php-mbstring']) {
        package { 'php-mbstring':
            ensure => present,
        }
    }

    if ! defined(Package['php-apcu']) {
        package { 'php-apcu':
            ensure => present,
        }
    }

    if ! defined(Package['php-mysql']) {
        package { 'php-mysql':
            ensure => present,
        }
    }

    package { 'python-pygments':
        ensure => present,
    }

    letsencrypt::cert::integrated { 'phabricator':
        subjects   => 'phabricator.wiki.org.uk',
        puppet_svc => 'nginx',
        system_svc => 'nginx',
    }

    nginx::conf { 'phabricator.wiki.org.uk':
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

    file { '/srv/phab/images':
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
        notify  => Service['nginx'],
        require => Git::Clone['phabricator'],
    }

    file { '/srv/phab/phabricator/support/preamble.php':
        ensure  => present,
        source => 'puppet:///modules/phabricator/preamble.php',
        notify  => Service['nginx'],
        require => Git::Clone['phabricator'],
    }

    file { '/etc/systemd/system/phd.service':
        ensure => present,
        source => 'puppet:///modules/phabricator/phd.systemd',
    }

    service { 'phd':
        ensure  => 'running',
        require => [File['/etc/systemd/system/phd.service'], File['/srv/phab/phabricator/conf/local/local.json']],
    }
}
