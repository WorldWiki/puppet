# servers

node 'mw1.wiki.org.uk' {
    include base
    include icinga2
    include icinga2::web
    include role::irc
    include role::mediawiki
    include role::mail
    include role::phabricator
    include role::redis
}

node 'world-wiki-main.c.world-wiki.internal' {
    include base
    include puppetmaster
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
