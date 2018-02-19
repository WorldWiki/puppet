# role: irc
class role::irc {
    include irc::irclogbot

    class { 'irc::ircrcbot':
        nickname     => 'WorldWikiRC',
        network      => 'chat.freenode.net',
        network_port => '6667',
        channel      => '#worldwiki-operations',
        udp_port     => '5070',
        sleeptime    => '0.5',
    }

    #ufw::allow { 'ircrcbot port mw1':
        #proto => 'udp',
        #port  => '5070',
        #from  => '185.52.1.75',
    #}

    #ufw::allow { 'ircrcbot port mw2':
     #   proto => 'udp',
      #  port  => '5070',
       # from  => '185.52.2.113',
    #}
    #ufw::allow { 'ircrcbot port mw3':
     #   proto => 'udp',
      #  port  => '5070',
       # from  => '81.4.121.113',
    #}

    motd::role { '::irc':
        description => 'IRC bots server',
    }
}
