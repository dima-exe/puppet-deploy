#
class deploy::fix::mongodb() {
  file { '/etc/logrotate.d/mongodb':
    content => template('deploy/fix/mongodb_logrotate.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }
}
