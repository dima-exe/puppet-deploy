require 'spec_helper'

describe 'deploy::nginx' do
  let(:title)  { 'my-app' }

  it { should contain_class("nginx") }
  it { should contain_class("deploy::params") }

  it do should contain_resource("Nginx::Site[my-app]").with(
    :content => /server_name my-app;/
  ) end

  context "with $server_name" do
    let(:params) { { :server_name => "example.com a.example.com:80 b.example.com:8080" } }
    it do should contain_resource("Nginx::Site[my-app]").with(
      :content => /server_name a.example.com example.com;/
    ) end
  end
end

