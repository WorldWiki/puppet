# servers

node 'puppet.wiki.org.uk' {
    include base
    include puppetmaster
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
