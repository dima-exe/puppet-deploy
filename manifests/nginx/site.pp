#
define deploy::nginx::site(
  $server_name,
  $document_root,
  $upstream     = undef,
  $auth_basic   = undef,
  $ssl_cert     = undef,
  $ssl_cert_key = undef,
  $ensure       = 'present',
  $sse_enable   = false
) {

  include 'nginx'

  $auth_basic_file = "/etc/nginx/${name}.httpasswd"

  $ssl_cert_file = $ssl_cert ? {
    undef   => undef,
    default => "/etc/nginx/ssl/${name}.crt"
  }

  $ssl_cert_key_file = $ssl_cert_key ? {
    undef   => undef,
    default => "/etc/nginx/ssl/${name}.key"
  }

  ::nginx::site{ $name:
    ensure  => $ensure,
    content => template('deploy/nginx/site.conf.erb')
  }

  if $ssl_cert_file != undef {
    file { $ssl_cert_file:
      ensure  => $ensure,
      source  => $ssl_cert,
      owner   => 'www-data',
      notify  => Service['nginx'],
      require => Package['nginx']
    }
  }

  if $ssl_cert_key_file != undef {
    file { $ssl_cert_key_file:
      ensure  => $ensure,
      source  => $ssl_cert_key,
      owner   => 'www-data',
      notify  => Service['nginx'],
      require => Package['nginx']
    }
  }

  if $auth_basic != undef  and $ensure == 'present' {
    validate_array($auth_basic)

    file{ $auth_basic_file:
      content => inline_template('<%= @auth_basic.join "\n" %>'),
      mode    => '0600',
      owner   => 'www-data',
      notify  => Service['nginx'],
      require => Package['nginx']
    }
  }

  if $ensure == 'absent' {
    file { $auth_basic_file:
      ensure => 'absent'
    }
  }
}
