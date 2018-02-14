# = Class: icinga2::ircbot
#
# Sets up an ircecho instance that sends icinga alerts to IRC
class icinga2::ircbot(
    $ensure='present'
) {
    if $ensure == 'present' {
        $ircecho_logs   = {
            '/var/log/icinga2/irc.log' => '#wikiopen-operations',
        }
        $ircecho_nick   = 'WikiopenServers'
        $ircecho_server = 'chat.freenode.net +6697'

        class { '::ircecho':
            ircecho_logs   => $ircecho_logs,
            ircecho_nick   => $ircecho_nick,
            ircecho_server => $ircecho_server,
        }
    }
}
