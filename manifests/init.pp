#
class deploy(
  $applications = undef,
  $rails        = undef,
  $mysql        = undef,
  $postgresql   = undef,
  $users        = undef,
  $mongodb      = undef,
  $sites        = undef,
  $services     = undef,
) {

  include 'deploy::params'

  $deploy_to = $deploy::params::deploy_to

  if $applications != undef or $rails != undef {
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
  }

  if $mysql != undef {
    create_resources('deploy::mysql', $mysql)
  }

  if $postgresql != undef {
    create_resources('deploy::postgresql', $postgresql)
  }

  if $users != undef {
    create_resources('deploy::user', $users)
  }

  if $mongodb != undef {
    create_resources('deploy::mongodb', $mongodb)
  }

  if $sites != undef {
    create_resources('deploy::nginx::site', $sites)
  }

  if $services != undef {
    create_resources('deploy::runit::service', $services)
  }
}
