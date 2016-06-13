class pve::profiles::common{
  package { 'git':
    ensure => 'installed',
  }

  package { 'vim':
    ensure => 'installed',
  }

  package { 'sudo':
    ensure => 'installed',
  }

  package { 'lsb-release':
    ensure => installed,
  }

  package { 'ca-certificates':
    ensure => installed,
  }

  file { "/opt/pve/apply.sh":
    mode => "700",
  }

  file { 'post-hook':
    ensure  => file,
    path    => '/opt/pve/.git/hooks/post-merge',
    source  => 'puppet:///pve/post-merge',
    mode    => 0755,
    owner   => root,
    group   => root,
  }
  cron { 'puppet-apply':
    ensure  => present,
    command => "cd /opt/pve ; /usr/bin/git pull",
    user    => root,
    minute  => '*/60',
    require => File['post-hook'],
  }
}