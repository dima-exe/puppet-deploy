require 'spec_helper'

describe "deploy::fix::nginx_server_names_hash_bucket_size", :type => :class do
  let(:file) { '/etc/nginx/conf.d/server_names_hash_bucket_size.conf' }

  it do should contain_file(file).with(
    :content => /.+/,
    :notify => 'Service[nginx]'
  ) end
end
