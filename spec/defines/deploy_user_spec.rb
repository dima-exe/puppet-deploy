require 'spec_helper'

describe "deploy::user" do
  let(:title) { 'my-user' }

  it { should include_class("deploy::params") }

  it do should contain_user("my-user").with(
    :ensure     => 'present',
    :groups     => nil,
    :system     => true,
    :managehome => true,
    :shell      => '/bin/bash',
    :home       => '/home/my-user'
  ) end

  it do should contain_file("/home/my-user").with(
    :ensure  => 'directory',
    :mode    => '0700',
    :require => 'User[my-user]'
  ) end

  context "when $groups" do
    let(:params) { { :groups => %w{ one two } } }
    it { should contain_user("my-user").with_groups(%w{ one two }) }
  end

  context "when $ssh_key" do
    let(:params) { { :ssh_key => 'ssh key' } }

    it do should contain_file("/home/my-user/.ssh").with(
      :ensure  => 'directory',
      :mode    => '0700',
      :owner   => 'my-user',
      :require => 'User[my-user]'
    ) end

    it do should contain_file("/home/my-user/.ssh/authorized_keys").with(
      :ensure  => 'present',
      :owner   => 'my-user',
      :group   => 'my-user',
      :mode    => '0600',
      :content => "ssh key\n",
      :require => "File[/home/my-user/.ssh]"
    ) end

    context "is array" do
      let(:params) { { :ssh_key => %w{ssh key} } }
      it do should contain_file("/home/my-user/.ssh/authorized_keys").with(
        :content => "key\nssh\n"
      ) end
    end

    context "with options" do
      let(:params) { { :ssh_key =>  "key", :ssh_key_options => "foo=bar" } }
      it do should contain_file("/home/my-user/.ssh/authorized_keys").with(
        :content => "foo=bar key\n"
      ) end
    end
  end

  context "when $ensure is absent" do
    let(:params) { { :ensure => 'absent' } }

    it { should contain_user("my-user").with_ensure('absent') }
    it { should contain_file("/home/my-user").with_ensure('absent') }
  end
end
