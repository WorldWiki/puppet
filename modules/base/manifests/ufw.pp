# firewall for all servers
class base::ufw {
    include ::ufw

    ufw::allow { 'ssh':
        proto => 'tcp',
        port  => 22,
    }

    ufw::allow { 'nrpe':
        proto => 'tcp',
        port  => 5666,
    }

    ufw::allow { 'http':
        proto => 'tcp',
        port  => 80,
    }

    ufw::allow { 'http_nginx':
        proto => 'tcp',
        port  => 8080,
    }

    ufw::allow { 'https':
        proto => 'tcp',
        port  => 443,
    }

    file { '/root/ufw-fix':
        ensure => present,
        source => 'puppet:///modules/base/ufw/ufw-fix',
        mode   => '0755',
    }
}
