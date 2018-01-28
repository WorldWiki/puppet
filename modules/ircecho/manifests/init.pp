# IRC echo class
# To use this class, you must define some parameters; here's an example
# (leading hashes on channel names are added for you if missing):
# $ircecho_logs = {
#  "/var/log/nagios/irc.log" =>
#  ["wikimedia-operations","#wikimedia-tech"],
#  "/var/log/nagios/irc2.log" => "#irc2",
# }
# $ircecho_nick = "icinga-wm"
# $ircecho_server = "chat.freenode.net 6667"
class ircecho (
    $ircecho_logs,
    $ircecho_nick,
    $ircecho_server = 'chat.freenode.net 6667',
    $ensure = 'running',
) {

    require_package(['python-pyinotify', 'python-irc'])

    file { '/usr/local/bin/ircecho':
        ensure  => 'present',
        source  => 'puppet:///modules/ircecho/ircecho.py',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        notify  => Service['ircecho'],
    }

    file { '/etc/default/ircecho':
        ensure  => 'present',
        content => template('ircecho/default.erb'),
        owner   => 'root',
        mode    => '0755',
        notify  => Service['ircecho'],
    }

    file { '/etc/init.d/ircecho':
        ensure => present,
        mode   => '0755',
        content => template('ircecho/initscripts/ircecho.sysvinit.erb'),
    }

    exec { 'Ircecho reload systemd':
        command     => '/bin/systemctl daemon-reload',
        refreshonly => true,
    }

    file { '/etc/systemd/system/ircecho.service':
        ensure => present,
        content => template('ircecho/initscripts/ircecho.systemd.erb'),
        notify => Exec['Ircecho reload systemd'],
    }

    service { 'ircecho':
        ensure     => $ensure,
        hasrestart => true,
        restart    => '/bin/systemctl reload icinga2',
        require    => File['/usr/local/bin/ircecho'],
    }
}

