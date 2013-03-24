#
define deploy::application(
  $ensure     = 'present',
  $user       = $name,
  $ssh_key    = undef,
  $deploy_to  = undef,
  $runit      = undef
) {

  include 'deploy::params'

  $deploy_path = $deploy_to ? {
    undef   => "${deploy::params::deploy_to}/${name}",
    default => $deploy_to
  }

  user { $user:
    ensure     => present,
    system     => true,
    managehome => true,
    shell      => '/bin/bash',
    home       => "/home/${user}"
  }

  file{ $deploy_path:
    ensure  => 'directory',
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => User[$user]
  }

  file{["${deploy_path}/shared",
        "${deploy_path}/current"]:
    ensure  => 'directory',
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => File[$deploy_path]
  }

  file { ["${deploy_path}/shared/config",
          "${deploy_path}/shared/log",
          "${deploy_path}/shared/pids"]:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => File["${deploy_path}/shared"]
  }

  file { "/home/${user}/.ssh":
    ensure  => 'directory',
    mode    => '0700',
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

  $key_content = $ssh_key ? {
    undef   => '',
    default => inline_template('<%= [ssh_key].flatten.join("\n") %>')
  }
  file { "/home/${user}/.ssh/authorized_keys":
    ensure  => 'present',
    owner   => $user,
    group   => $user,
    mode    => '0600',
    content => $key_content,
    require => File["/home/${user}/.ssh"]
  }

  if $runit != undef {
    deploy::runit { $name:
      deploy_to => $deploy_path,
      user      => $user
    }
  }
}
