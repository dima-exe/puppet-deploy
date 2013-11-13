require 'spec_helper'

describe "deploy::rabbitmq", :type => :define do
  let(:title) { 'my-user' }
  let(:default_params) { { 'vhost' => 'vhost', 'password' => 'pass' } }
  let(:params) { default_params }
  let(:facts) { {:osfamily => "Debian"} }

  it { should include_class("rabbitmq") }


  it do should contain_resource("Rabbitmq_vhost[vhost]").with(
    :ensure => 'present'
  ) end

  it do should contain_resource("Rabbitmq_user[my-user]").with(
    :ensure   => 'present',
    :admin    => false,
    :password => 'pass'
  ) end

  it do should contain_resource("Rabbitmq_user_permissions[my-user@vhost]").with(
    :configure_permission => ".*",
    :read_permission      => ".*",
    :write_permission     => ".*"
  ) end

  context "when $ensure is absent" do
    let(:params) { default_params.merge :ensure => "absent" }
    it do should contain_resource("Rabbitmq_user[my-user]").with(
      :ensure   => 'absent'
    ) end
  end

  context "when $admin is true" do
    let(:params) { default_params.merge :admin => true }
    it do should contain_resource("Rabbitmq_user[my-user]").with(
      :admin   => true
    ) end
  end

end
