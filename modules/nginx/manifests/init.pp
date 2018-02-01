# nginx
class nginx {
    include ::apt

    if os_version('ubuntu == xenial') {
        apt::source { 'nginx_apt':
            comment  => 'NGINX stable',
            location => 'http://nginx.org/packages/ubuntu',
            release  => 'xenial',
            repos    => 'nginx',
            key      => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62',
        }

        package { 'nginx':
            ensure  => present,
            require => [ Apt::Source['nginx_apt'], Package['apache2'] ],
            notify  => Exec['nginx unmask'],
        }
    } else {
        package { 'nginx':
            ensure  => present,
            notify  => Exec['nginx unmask'],
        }
    }

    file { [ '/etc/nginx', '/etc/nginx/sites-available', '/etc/nginx/sites-enabled' ]:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        notify => Service['nginx'],
    }

    file { '/etc/nginx/mime.types':
        ensure => present,
        source => 'puppet:///modules/nginx/mime.types',
    }

    exec { 'nginx unmask':
        command     => '/bin/systemctl unmask nginx.service',
        refreshonly => true,
    }

    service { 'nginx':
        ensure     => 'running',
        enable     => true,
        hasrestart => true,
        require    => [ Exec['nginx unmask'], File['/etc/nginx/mime.types'] ],
    }

    file { '/etc/logrotate.d/nginx':
        ensure => present,
        source => 'puppet:///modules/nginx/logrotate',
    }
}
