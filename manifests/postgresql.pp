#
define deploy::postgresql(
  $password  = undef,
  $databases = [],
  $superuser = false
) {
  validate_array($databases)

  $real_password = $password ? {
    undef   => $name,
    default => $password
  }

  postgresql::database{ $databases:
    charset => 'unicode',
    locale  => 'en_US',
    require => Class['postgresql::config']
  }

  postgresql::role{ $name:
    password_hash => postgresql_password($name, $real_password),
    superuser     => $superuser,
    login         => true,
    createdb      => true,
    require       => Class['postgresql::config']
  }

  if $superuser == false {

    if size($databases) > 0 {
      postgresql::database_grant{ $name:
        privilege => 'ALL',
        db        => $databases,
        role      => $name,
        require   => [Postgresql::Database_role[$name],
                      Postgresql::Database[$databases]]
      }
    }
  }
}
