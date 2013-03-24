#
define deploy::rails(
  $ensure          = 'present',
  $user            = $name,
  $ssh_key         = undef,
  $deploy_to       = undef,

  $database_url    = undef,
  $resque_url      = undef,
  $env             = 'production',
  $num_web_workers = 2
) {
  include 'deploy::params'

  $deploy_path = $deploy_to ? {
    undef   => "${deploy::params::deploy_to}/${name}",
    default => $deploy_to
  }

  deploy::application{ $name:
    ensure    => 'present',
    user      => $user,
    ssh_key   => $ssh_key,
    deploy_to => $deploy_path
  }

  File {
    require => Deploy::Application[$name]
  }

  if $database_url != undef {
    file { "${deploy_path}/shared/config/database.yml":
      ensure  => 'present',
      owner   => $user,
      group   => $user,
      mode    => '0640',
      content => template('deploy/database.yml.erb')
    }
  }

  if $resque_url != undef {
    file { "${deploy_path}/shared/config/resque.yml":
      ensure  => 'present',
      owner   => $user,
      group   => $user,
      mode    => '0640',
      content => template('deploy/resque.yml.erb')
    }
  }

  file{ "${deploy_path}/shared/config/unicorn.rb":
    ensure  => 'present',
    owner   => $user,
    group   => $user,
    mode    => '0640',
    content => template('deploy/unicorn.rb.erb'),
  }
}
