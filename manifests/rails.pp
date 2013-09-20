#
define deploy::rails(
  $ensure          = 'present',
  $user            = $name,
  $ssh_key         = undef,
  $ssh_key_options = undef,
  $deploy_to       = undef,
  $supervisor      = undef,
  $configs         = undef,

  $server_name     = undef,
  $database_url    = undef,
  $env             = 'production',
  $num_web_workers = 2,
  $listen_addr     = '127.0.0.1:3000'
) {
  include 'deploy::params'

  $deploy_path = $deploy_to ? {
    undef   => "${deploy::params::deploy_to}/${name}",
    default => $deploy_to
  }

  deploy::application{ $name:
    ensure          => 'present',
    user            => $user,
    ssh_key         => $ssh_key,
    ssh_key_options => $ssh_key_options,
    deploy_to       => $deploy_path,
    supervisor      => $supervisor,
    configs         => $configs
  }

  file{
    "${deploy_path}/shared/config/unicorn.rb":
      ensure  => 'present',
      owner   => $user,
      group   => $user,
      mode    => '0640',
      content => template('deploy/unicorn.rb.erb'),
      require => File["${deploy_path}/shared/config"];
    "${deploy_path}/shared/config/puma.rb":
      ensure  => 'present',
      owner   => $user,
      group   => $user,
      mode    => '0640',
      content => template('deploy/puma.rb.erb'),
      require => File["${deploy_path}/shared/config"];
  }

  if $database_url != undef {
    file { "${deploy_path}/shared/config/database.yml":
      ensure  => 'present',
      owner   => $user,
      group   => $user,
      mode    => '0640',
      content => template('deploy/database.yml.erb'),
      require => File["${deploy_path}/shared"]
    }
  }

  if $server_name != undef {
    include 'nginx'

    nginx::site{ $name:
      content => template('deploy/nginx_rails.conf.erb'),
    }
  }
}
