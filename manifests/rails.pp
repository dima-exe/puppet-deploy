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
  $listen_addr     = '127.0.0.1:3000',

  $ssl_cert        = undef,
  $ssl_cert_key    = undef,
  $auth_basic      = undef,

  $puma_threads    = '1,1'
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

    $nginx_upstream = $listen_addr ? {
      undef   => "unix:${deploy_path}/shared/pids/web.sock",
      default => $listen_addr
    }

    deploy::nginx::site{ $name:
      ensure        => 'present',
      server_name   => $server_name,
      upstream      => $nginx_upstream,
      document_root => "${deploy_path}/current/public",
      ssl_cert      => $ssl_cert,
      ssl_cert_key  => $ssl_cert_key,
      auth_basic    => $auth_basic,
    }
  }
}
