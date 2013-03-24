#
define deploy::runit(
  $user      = $name,
  $deploy_to = undef,
) {
  include 'runit'
  include 'deploy::params'

  $deploy_path = $deploy_to ? {
    undef   => "${deploy::params::deploy_to}/${name}",
    default => $deploy_to
  }

  file{"${deploy_path}/services":
    ensure  => 'directory',
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => File[$deploy_path]
  }

  runit::service { $name:
    user       => $user,
    group      => $user,
    rundir     => "${deploy_path}/services",
    command    => "runsvdir ${deploy_path}/services",
    require    => File["${deploy_path}/services"]
  }
}
