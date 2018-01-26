# servers

node 'phabricator-2-vm.c.world-wiki.internal' {
    include base
    include puppetmaster
    include role::phabricator
}

node 'mw1.wiki.org.uk' {
    include base
    include role::irc
    include role::mediawiki
}

node 'world-wiki-main.c.world-wiki.internal' {
    include base
    include puppetmaster
    include role::phabricator
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
