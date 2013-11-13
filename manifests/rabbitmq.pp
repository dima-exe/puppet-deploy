#
define deploy::rabbitmq(
  $ensure               = 'present',
  $vhost                = undef,
  $password             = undef,
  $admin                = false,
  $configure_permission = '.*',
  $read_permission      = '.*',
  $write_permission     = '.*'
) {
  include 'rabbitmq'

  if ! defined(Rabbitmq_vhost[$vhost]) {
    rabbitmq_vhost { $vhost:
      ensure   => 'present',
    }
  }

  rabbitmq_user { $name:
    ensure   => $ensure,
    admin    => $admin,
    password => $password,
  }

  rabbitmq_user_permissions { "${name}@${vhost}":
    configure_permission => $configure_permission,
    read_permission      => $read_permission,
    write_permission     => $write_permission,
  }
}
