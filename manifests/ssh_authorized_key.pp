#
define deploy::ssh_authorized_key(
  $ssh_key         = undef,
  $user            = $name,
  $options         = undef
) {
  include 'deploy::params'

  $key_content = deploy_ssh_authorized_key_content($ssh_key, {
    key_options => $options, cache_path => $deploy::params::keys_cache_path
  })

  file { "/home/${user}/.ssh":
    ensure  => 'directory',
    mode    => '0700',
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

  file { "/home/${user}/.ssh/authorized_keys":
    ensure  => 'present',
    owner   => $user,
    group   => $user,
    mode    => '0600',
    content => $key_content,
    require => File["/home/${user}/.ssh"]
  }
}
