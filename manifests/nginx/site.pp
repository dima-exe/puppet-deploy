#
define deploy::nginx::site(
  $server_name,
  $document_root,
  $is_rails   = false,
  $upstream   = undef,
  $auth_basic = undef,
  $ensure     = 'present'
) {

  include 'nginx'

  $auth_basic_file = "/etc/nginx/${name}.httpasswd"

  ::nginx::site{ $name:
    ensure  => $ensure,
    content => template('deploy/nginx/site.conf.erb')
  }

  if $auth_basic != undef  and $ensure == 'present' {
    validate_array($auth_basic)

    file{ $auth_basic_file:
      content => inline_template('<%= @auth_basic.join "\n" %>'),
      mode    => '0600',
      owner   => 'www-data'
    }
  }

  if $ensure == 'absent' {
    file { $auth_basic_file:
      ensure => 'absent'
    }
  }
}
