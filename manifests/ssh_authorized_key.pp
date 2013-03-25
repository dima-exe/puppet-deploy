#
define deploy::ssh_authorized_key(
  $ssh_key = undef,
  $user    = $name
) {

  $key_content = $ssh_key ? {
    undef   => '',
    default => inline_template('<%= [ssh_key].flatten.join("\n") %>')
  }

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
