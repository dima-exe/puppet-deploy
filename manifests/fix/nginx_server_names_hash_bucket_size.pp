#
class deploy::fix::nginx_server_names_hash_bucket_size() {
  file { '/etc/nginx/conf.d/server_names_hash_bucker_size.conf':
    content => "server_names_hash_bucket_size 64;\n",
    notify  => Service['nginx']
  }
}
