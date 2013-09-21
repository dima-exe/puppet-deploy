#
define deploy::nginx::site(
  $server_name,
  $document_root,
  $is_rails = false,
  $upstream = undef,
  $ensure   = 'present'
) {

  include 'nginx'

  ::nginx::site{ $name:
    ensure  => $ensure,
    content => template('deploy/nginx/site.conf.erb')
  }
}
