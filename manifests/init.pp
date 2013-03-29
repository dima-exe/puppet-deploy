#
class deploy(
  $applications = undef,
  $rails        = undef,
  $mysql        = undef,
  $postgresql   = undef
) {

  include 'deploy::params'

  $deploy_to = $deploy::params::deploy_to

  exec { "/bin/mkdir -p ${deploy_to}":
    creates => $deploy_to
  }

  $defaults = {
    require => Exec["/bin/mkdir -p ${deploy_to}"]
  }

  if $applications != undef {
    create_resources('deploy::application', $applications, $defaults)
  }

  if $rails != undef {
    create_resources('deploy::rails', $rails, $defaults)
  }

  if $mysql != undef {
    create_resources('deploy::mysql', $mysql)
  }

  if $postgresql != undef {
    create_resources('deploy::postgresql', $postgresql)
  }
}
