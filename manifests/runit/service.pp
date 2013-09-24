#
define deploy::runit::service(
  $command,
  $rundir,
  $user   = $name,
  $ensure = 'present'
) {

  include 'runit'

  ::runit::service { $name:
    ensure  => $ensure,
    user    => $user,
    group   => $user,
    rundir  => $rundir,
    command => $command,
    logger  => true,
  }
}
