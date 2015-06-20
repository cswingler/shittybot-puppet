class shittybot { 
  # This module has been tested on Debian 8 (Jessie) with Puppet 3.7.2, on a 
  # local puppet apply run. 

  # In addition, it's been a while since I've actually written a Puppet module,
  # and http://i.imgur.com/0pePmV7.jpg may apply thanks to writing lots of Chef
  # cookbooks as of late.

  # This manifest requires meltwater/cpan.

  $perl_dpkgs = [ 
    'libanyevent-irc-perl',
    'libtcl-perl', 
    'libmoose-perl',
    'libtime-out-perl',
    'libcarp-always-perl',
    'libdata-dump-perl',
    'libconfig-any-perl',
    'libconfig-general-perl',
    'libnet-scp-expect-perl'] 
  # libparent-perl is part of perl-modules, and meltwater/cpan adds perl-modules.

  $perl_cpanpkgs = [
    'YAML::XS'
    ] 

  $tcl_dpkgs = [
    'tcl-dev',
    'tcllib',
    'tclcurl',
    'tclx8.4'
  ]

  $other_pkgs = ['git']

  package { $perl_dpkgs: } 
  package { $tcl_dpkgs: } 
  package { $other_pkgs: }

  # Here's where meltwater/cpan comes into play:
  include cpan
  cpan { $perl_cpanpkgs: 
    ensure => present,
    require => Class['::cpan']
  }

  # Set up a user/directory for shittybot to live in:
  $shittybot_home = '/var/lib/shittybot'
  user { 'shittybot':
    ensure => present,
    comment => 'A bad IRC bot.',
    home => $shittybot_home,
    managehome => true,
    shell => '/bin/bash'
  }

  # Okay, here's where we start getting into interesting bits. This requires puppetlabs/vcsrepo.
  # Check out the shittybot source code into shittybot's homedir:

  vcsrepo { "${shittybot_home}/exec":
    ensure => present,
    provider => "git",
    source  => "https://github.com/exp/smeggdrop.git",
    owner => "shittybot",
    require => User['shittybot']
  }

  # And then check out the procs:

  vcsrepo { "${shittybot_home}/exec/state":
    ensure => present,
    provider => 'git',
    source => 'https://github.com/baileybot/smeggdrop-proc.git',
    owner => "shittybot",
    require => Vcsrepo["${shittybot_home}/exec"]
  }
}


include shittybot
