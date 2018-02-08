# servers

node 'mw1.worldwiki.tk' {
    include base
    include icinga2
    include icinga2::web
    include role::irc
    include role::mediawiki
    include role::mail
    include role::phabricator
    include puppetmaster
    include role::redis
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
