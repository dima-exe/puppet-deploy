#
define deploy::user(
  $ensure          = 'present',
  $groups          = undef,
  $ssh_key         = undef,
  $ssh_key_options = undef,
) {
  include 'deploy::params'

  user { $name:
    ensure     => $ensure,
    groups     => $groups,
    system     => true,
    managehome => true,
    shell      => '/bin/bash',
    home       => "/home/${name}"
  }

  if $ensure == 'absent' {
    file { "/home/${name}":
      ensure => 'absent'
    }
  }

  if $ensure == 'present' {

    file { "/home/${name}":
      ensure  => 'directory',
      mode    => '0700',
      require => User[$name]
    }

    if $ssh_key != undef {

      $key_content = deploy_ssh_authorized_key_content($ssh_key, {
        key_options => $ssh_key_options,
        cache_path  => $deploy::params::keys_cache_path
      })

      file { "/home/${name}/.ssh":
        ensure  => 'directory',
        mode    => '0700',
        owner   => $name,
        group   => $name,
        require => User[$name]
      }

      file { "/home/${name}/.ssh/authorized_keys":
        ensure  => 'present',
        owner   => $name,
        group   => $name,
        mode    => '0600',
        content => $key_content,
        require => File["/home/${name}/.ssh"]
      }
    }
  }
}
