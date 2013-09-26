#
class deploy::fix::nginx_server_names_hash_bucket_size(
  $size = 64
) {

  if defined(Service['nginx']) {
    file { '/etc/nginx/conf.d/server_names_hash_bucket_size.conf':
      content => "server_names_hash_bucket_size ${size};\n",
      notify  => Service['nginx'],
      require => Package['nginx']
    }
  }
}
