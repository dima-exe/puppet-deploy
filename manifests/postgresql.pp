#
define deploy::postgresql(
  $password  = undef,
  $database  = undef,
  $superuser = false
) {
  $real_password = $password ? {
    undef   => $name,
    default => $password
  }

  if $superuser == true {

    if $database != undef {
      postgresql::database{ $database:
        locale  => 'en_US.UTF-8',
        require => Class['postgresql::config']
      }
    }

    postgresql::role{ $name:
      password_hash => postgresql_password($name, $real_password),
      superuser     => true,
      login         => true,
      createdb      => true,
      require       => Class['postgresql::config']
    }
  } else {
    if $database != undef {
      postgresql::db { $database:
        user     => $name,
        password => postgresql_password($name, $real_password),
        grant    => 'all',
        locale   => 'en_US.UTF-8',
        require  => Class['postgresql::config']
      }
    }
  }
}
