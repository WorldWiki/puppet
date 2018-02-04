# class: irc
class irc {
    $packages = [
        'python',
        'python-twisted',
        'python-requests',
        'python-requests-oauthlib',
    ]

    package { $packages:
        ensure => present,
    }

    if ! defined(Package['python-irc']) {
        package { 'python-irc':
            ensure => present,
        }
    }
}
