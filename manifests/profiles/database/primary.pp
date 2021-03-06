class pve::profiles::database::primary{
  $db = hiera_hash('pve::profiles::database')

  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.4',
    encoding            => 'UTF-8',
    locale              => 'nb_NO.UTF-8',
  }-> class { 'postgresql::server':
    listen_addresses           => '*',
  }

  ### Standby configuration for primary db server.
  # configure postgres with hot standby as described here: https://cloud.google.com/solutions/setup-postgres-hot-standby
  postgresql::server::config_entry { 'wal_level':
    value => 'hot_standby',
  }
  postgresql::server::config_entry { 'archive_mode':
    value => 'on',
  }
  postgresql::server::config_entry { 'archive_command':
    value => 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f',
  }
  postgresql::server::config_entry { 'max_wal_senders':
    value => '3',
  }

  postgresql::server::role { "repuser":
    replication      => true,
    connection_limit => 5,
    password_hash    => postgresql_password("repuser", "${db['password']}"),
  }

  postgresql::server::pg_hba_rule { "allow repuser from db-2 to replicate the database":
    description => "Open up replication for access from network",
    type        => 'host',
    database    => "replication",
    user        => "repuser",
    address     => '10.0.3.6/32',
    auth_method => 'md5',
  }
  ## end.

  postgresql::server::pg_hba_rule { "allow all to access all database":
    description => "Open up PostgreSQL for access from network",
    type        => 'host',
    database    => "all",
    user        => "all",
    address     => '0.0.0.0/0',
    auth_method => 'md5',
  }

}