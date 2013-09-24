require 'spec_helper'

describe "deploy::nginx::site", :type => :define do
  let(:title)  { 'my-app' }
  let(:default_params) { {
    :server_name   => 'example.com a.example.com:80 b.example.com:8080',
    :document_root => "document_root"
  } }
  let(:params) { default_params }

  it { should include_class('nginx') }

  it do should contain_resource("Nginx::Site[my-app]").with(
    :content => /listen 80;\n  server_name a.example.com example.com;\n/
  ) end

  it do should contain_resource("Nginx::Site[my-app]").with(
    :content => /listen 8080;\n  server_name b.example.com;\n/
  ) end

  it do should contain_resource("Nginx::Site[my-app]").with(
    :content => /root document_root/
  ) end

  context "with $upstream" do
    let(:params) { default_params.merge :upstream => "127.0.0.1:3000" }

    it do should contain_resource("Nginx::Site[my-app]").with(
      :content => /upstream my_app_upstream/
    ) end

    it do should contain_resource("Nginx::Site[my-app]").with(
      :content => /location @app/
    ) end

    it do should contain_resource("Nginx::Site[my-app]").with(
      :content => /server 127.0.0.1:3000/
    ) end

    it do should contain_resource("Nginx::Site[my-app]").with(
      :content => /try_files/
    ) end
  end

  context "with $auth_basic" do
    let(:params) { default_params.merge :auth_basic => %w{ foo:bar } }

    it do should contain_file("/etc/nginx/my-app.httpasswd").with(
      :content => "foo:bar",
      :mode    => '0600',
      :owner   => 'www-data'
    ) end

    it do should contain_resource("Nginx::Site[my-app]").with(
      :content => /auth_basic_user_file/
    ) end
  end

end
