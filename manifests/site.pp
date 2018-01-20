# servers

node 'phabricator-2-vm.c.world-wiki.internal' {
    include base
    include puppetmaster
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
