#
define deploy::mongodb(
  $database  = $name,
  $password  = $name,
  $ensure    = 'present',
  $superuser = false
) {
  include 'mongodb'
  include 'deploy::fix::mongodb'

  $servicename = $mongodb::servicename

  case $ensure {
    'present': {
      $user_db = $superuser ? {
        true    => 'admin',
        default => $database
      }

      $add_user_js   = "db.addUser('${name}', '${password}')"
      $check_user_js = "db.auth('${name}', '${password}')"
      $add_user      = "/usr/bin/mongo ${user_db} --eval \"${add_user_js}\""
      $check_user    = "/usr/bin/mongo ${user_db} --eval \"${check_user_js}\" | grep 'auth fails'"

      exec{ "add ${name} mongo user":
        command => $add_user,
        onlyif  => $check_user,
        require => Service[$servicename]
      }
    }
    'absent': {
    }
    default: { fail('ensure must be present or absent') }
  }
}

