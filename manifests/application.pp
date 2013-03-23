#
define deploy::application(
  $ensure     = 'present',
  $user       = $name,
  $ssh_key    = undef,
  $deploy_to  = undef
) {

  include 'deploy::params'

  $deploy_path = $deploy_to ? {
    undef   => "${deploy::params::deploy_to}/${name}",
    default => $deploy_to
  }

  group { $user:
    ensure => 'present'
  }

  user { $user:
    ensure     => present,
    system     => true,
    managehome => true,
    shell      => '/bin/bash',
    home       => "/home/${user}",
    require    => Group[$user],
  }

  file{ $deploy_path:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0755',
    require => User[$user]
  }

  file{["${deploy_path}/shared",
        "${deploy_path}/services",
        "${deploy_path}/current"]:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0755',
    require => File[$deploy_path]
  }

  file { ["${deploy_path}/shared/config",
          "${deploy_path}/shared/log",
          "${deploy_path}/shared/pids"]:
    ensure  => directory,
    owner   => $user,
    mode    => '0755',
    require => File["${deploy_path}/shared"]
  }

  file { "/home/${user}/.ssh":
    ensure  => 'directory',
    mode    => '0700',
    owner   => $user,
    require => User[$user]
  }

  file { "/home/${user}/.ssh/authorized_keys":
    ensure  => 'present',
    owner   => $user,
    mode    => '0600',
    content => inline_template('<%= ((ssh_key == :undef ? nil : (ssh_key.is_a?(Array) ? ssh_key : [ssh_key] )) || []).join("\n") %>'),
    require => File["/home/${user}/.ssh"]
  }
}
