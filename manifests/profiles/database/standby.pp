class pve::profiles::database::standby{

  $db = hiera_hash('pve::profiles::database')

  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.4',
    encoding            => 'UTF-8',
    locale              => 'nb_NO.UTF-8',
  }-> class { 'postgresql::server':
    manage_recovery_conf       => true,
    listen_addresses           => '*',
  }

  postgresql::server::config_entry { 'hot_standby':
    value => 'on',
  }

  postgresql::server::recovery{ 'Create a recovery.conf file with the following defined parameters':
    restore_command                => 'cp /var/lib/postgresql/9.4/main/mnt/server/archivedir%f %p',
    archive_cleanup_command        => 'pg_archivecleanup /var/lib/postgresql/9.4/main/mnt/server/archivedir %r',
    standby_mode                   => 'on',
    primary_conninfo               => 'host=db-1.dragon.lan port=5432 user=repuser password=password1',
    require                        => Exec["pg_basebackup"]
  }

  postgresql::server::pg_hba_rule { "allow ${ db['user'] } to access ${ db['name'] } database":
    description => "Open up PostgreSQL for access from network",
    type        => 'host',
    database    => "${db['name']}",
    user        => "${db['user']}",
    address     => '0.0.0.0/0',
    auth_method => 'md5',
    notify      => Service['postgresqld']
  }

  exec { "pg_basebackup":
    environment => "PGPASSWORD=password1",
    command     => "/usr/bin/pg_basebackup -X stream -D /var/lib/postgresql/9.4/main -h db-1.dragon.lan -U repuser -w",
    user        => 'postgres',
    unless      => "/usr/bin/test -f /var/lib/postgresql/9.4/main/PG_VERSION",
    logoutput => true,
  }

}