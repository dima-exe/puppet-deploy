#
define deploy::mysql(
  $password  = undef,
  $databases = [],
  $superuser = false
) {
  validate_array($databases)

  $real_password = $password ? {
    undef   => $name,
    default => $password
  }

  database_user{ $name:
    password_hash => mysql_password($real_password),
    provider      => 'mysql',
    require       => Class['mysql::config'],
  }

  if $superuser == true {
    database_grant{ $name:
      privileges    => ['all'],
      require       => Database_user[$name]
    }
  }

  if size($databases) > 0 {
    database { $databases:
      ensure  => 'present',
      require => Database_user[$name]
    }

    if $superuser == false {
      $grant = regsubst($databases, '^(.*)$', "${name}/\1")
      database_grant{ $grant:
        privileges    => ['all'],
        require       => Database_user[$name]
      }
    }
  }
}
