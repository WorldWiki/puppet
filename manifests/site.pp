# servers

node 'phabricator-2-vm.c.world-wiki.internal' {
    include base
    include puppetmaster
    include role::phabricator
}

node 'ip-172-31-3-168-9a33ab41.c.world-wiki.internal' {
    include base
    include role::irc
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
