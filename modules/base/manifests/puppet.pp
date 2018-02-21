# class base::puppet
class base::puppet {

    $puppetmaster_hostname = hiera('puppetmaster_hostname', 'vps504112')
    $puppetmaster_version = hiera('puppetmaster_version', 4)

    cron { 'puppet-run-no-force':
        ensure  => absent,
        command => '/root/puppet-run &> /var/log/puppet-run.log',
        user    => 'root',
        minute  => [ 20, 30, 40, 50 ],
    }

    cron { 'puppet-run-force':
        ensure  => absent,
        command => '/root/puppet-run -f &> /var/log/puppet-run.log',
        user    => 'root',
        hour    => '*',
        minute  => '0',
    }

    cron { 'logrotate':
        command => 'apt update && apt-get upgrade -y',
        user    => 'root',
        hour    => '4',
        day     => ['1-7'],
        minute  => '0',
}

    cron { 'puppet-agent':
        command => '/usr/bin/puppet agent -t',
        user    => 'root',
        hour    => '*',
        minute  => '*/20',
    }

    file { '/root/puppet-run':
        ensure => absent,
        source => 'puppet:///modules/base/puppet/puppet-run',
        mode   => '0775',
    }

    if !hiera('puppetmaster') {
        file { '/etc/puppet/puppet.conf':
            ensure  => present,
            content => template("base/puppet/puppet_${puppetmaster_version}.conf.erb"),
            mode    => '0444',
        }
    }

    service { 'puppet':
        ensure => stopped,
    }
}
