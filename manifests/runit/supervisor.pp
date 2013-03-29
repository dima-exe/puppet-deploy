#
define deploy::runit::supervisor(
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
  }

  $finish_tmpl = template('deploy/runit_finish.sh.erb')

  runit::service { $name:
    user           => $user,
    group          => $user,
    rundir         => "${deploy_path}/services",
    command        => "runsvdir -P ${deploy_path}/services",
    finish_content => $finish_tmpl,
    logger         => false,
    require        => File["${deploy_path}/services"]
  }
}
