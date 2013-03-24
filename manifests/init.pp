#
class deploy(
  $applications = undef,
  $rails        = undef,
  $mysql        = undef,
  $postgresql   = undef,
  $nginx        = undef
) {

  include 'deploy::params'

  $deploy_to = $deploy::params::deploy_to

  Exec["/bin/mkdir -p ${deploy_to}"] -> Deploy::Application <| |>

  exec { "/bin/mkdir -p ${deploy_to}":
    creates => $deploy_to
  }

  if $applications != undef {
    create_resources('deploy::application', $applications)
  }

  if $rails != undef {
    create_resources('deploy::rails', $rails)
  }

  if $mysql != undef {
    create_resources('deploy::mysql', $mysql)
  }

  if $postgresql != undef {
    create_resources('deploy::postgresql', $postgresql)
  }
}
