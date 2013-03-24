#
class deploy::fix::postgresql_template1_encoding() {

  $file  = '/var/lib/postgresql/fix_template1_encoding.sql'

  file { $file:
    owner   => 'postgres',
    content => template('deploy/fix/postgres_template1_encoding.sql'),
    require => Class['postgresql::config']
  }

  exec { 'deploy::fix::postgresql_template1_encoding':
    user    => 'postgres',
    onlyif  => '/usr/bin/psql -c "\l" | grep template1 | grep SQL_ASCII',
    command => "/usr/bin/psql -f ${file}",
    require => File[$file]
  }

}
