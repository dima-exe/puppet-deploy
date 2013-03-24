#
define deploy::mysql(
  $password  = undef,
  $database  = undef,
  $superuser = false,
  $host      = 'localhost',
  $create_database = true
) {

  include 'mysql::server'

  $real_password = $password ? {
    undef   => $name,
    default => $password
  }

  $user = "${name}@${host}"

  database_user{ $user:
    password_hash => mysql_password($real_password),
    provider      => 'mysql',
    require       => Class['mysql::config'],
  }

  if $superuser == true {
    database_grant{ $user:
      privileges    => ['all'],
      require       => Database_user[$user]
    }
  }

  if $database != undef {

    if $create_database == true {
      database { $database:
        ensure  => 'present',
        require => Database_user[$user]
      }
    }

    if $superuser == false {
      $grant = regsubst($database, '^(.*)$', "${user}/\\1")
      database_grant{ $grant:
        privileges    => ['all'],
        require       => Database_user[$user]
      }
    }
  }
}
