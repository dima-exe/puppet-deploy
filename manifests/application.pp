#
define deploy::application(
  $ensure          = 'present',
  $user            = $name,
  $ssh_key         = undef,
  $ssh_key_options = undef,
  $deploy_to       = undef,
  $supervisor      = undef,
  $configs         = undef,
) {

  include 'deploy::params'

  $deploy_path = $deploy_to ? {
    undef   => "${deploy::params::deploy_to}/${name}",
    default => $deploy_to
  }

  deploy::user{ $user:
    ssh_key         => $ssh_key,
    ssh_key_options => $ssh_key_options
  }

  file{ $deploy_path:
    ensure  => 'directory',
    owner   => $user,
    group   => $user,
    mode    => '0775',
    require => User[$user]
  }

  file{["${deploy_path}/shared",
        "${deploy_path}/releases"]:
    ensure  => 'directory',
    owner   => $user,
    group   => $user,
    mode    => '0775',
    require => File[$deploy_path]
  }

  file { ["${deploy_path}/shared/config",
          "${deploy_path}/shared/log",
          "${deploy_path}/shared/pids"]:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0775',
    require => File["${deploy_path}/shared"]
  }

  if $supervisor != undef {
    deploy::runit::supervisor { $name:
      deploy_to => $deploy_path,
      user      => $user
    }
  }

  if $configs != undef {
    $files_hash = deploy_application_configs_to_files("${deploy_path}/shared/config", $configs)
    create_resources('file', $files_hash, { owner => $user, group => $user })
  }
}
