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
  $defaults  = { deploy_to => $deploy_to }

  exec { "/bin/mkdir -p ${deploy_to}":
    creates => $deploy_to
  }

  Exec["/bin/mkdir -p ${deploy_to}"] -> Deploy::Application <| |>
  Exec["/bin/mkdir -p ${deploy_to}"] -> Deploy::Rails <| |>

  if $applications != undef {
    create_resources('deploy::application', $applications, $defaults)
  }

  if $rails != undef {
    create_resources('deploy::rails', $rails, $defaults)
  }
}
