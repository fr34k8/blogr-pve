class pve::profiles::common{

  include unattended_upgrades
  
  class { 'timezone':
    timezone => 'Europe/Oslo',
  }

  class { 'apt':
    update => {
      frequency => 'daily',
    }
  }

  class { 'ssh::server':
    storeconfigs_enabled => false,
    options              => {
      'PermitRootLogin'  => 'yes',
    },
  }

  class { 'locales':
    default_locale  => 'nb_NO.UTF-8',
    locales         => ['en_US.UTF-8 UTF-8', 'nb_NO.UTF-8 UTF-8'],
  }

  package { 'git':
    ensure => 'installed',
  }

  package { 'vim':
    ensure => 'installed',
  }

  package { 'sudo':
    ensure => 'installed',
  }

  # https://tickets.puppetlabs.com/browse/FACT-866
  package { 'lsb-release':
    ensure => installed,
  }

  package { 'ca-certificates':
    ensure => installed,
  }

  file { "/opt/pve/apply.sh":
    mode => "744",
  }

  file { 'post-hook':
    ensure   => file,
    path     => '/opt/pve/.git/hooks/post-merge',
    content  => 'cd /opt/pve ; ./apply.sh',
    mode     => "0755",
    owner    => root,
    group    => root
  }->
  cron { 'puppet-apply':
    ensure  => present,
    command => "cd /opt/pve ; /usr/bin/git pull",
    user    => root,
    minute  => '*/60',
    require => File['post-hook']
  }

}
