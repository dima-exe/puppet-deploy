#
define deploy::nginx (
  $server_name = $name,
  $deploy_to   = undef
) {
  include 'nginx'
  include 'deploy::params'

  $deploy_path = $deploy_to ? {
    undef   => "${deploy::params::deploy_to}/${name}",
    default => $deploy_to
  }

  nginx::site{ $name:
    content => template('deploy/nginx.conf.erb'),
  }
}
