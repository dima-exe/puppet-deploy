require 'spec_helper'

describe "deploy::application" do
  let(:title) { 'my-app' }

  it { should include_class('deploy::params') }

  it do should contain_user('my-app').with(
    :ensure     => 'present',
    :system     => true,
    :managehome => true,
    :shell      => '/bin/bash',
    :home       => '/home/my-app'
  ) end

  it do should contain_file('/u/apps/my-app').with(
    :ensure => 'directory',
    :owner  => 'my-app',
    :mode   => '0755',
    :require => 'User[my-app]'
  ) end

  %w{ shared current }.each do |f|
    it do should contain_file("/u/apps/my-app/#{f}").with(
      :ensure  => 'directory',
      :owner   => 'my-app',
      :mode    => '0755',
      :require => 'File[/u/apps/my-app]'
    ) end
  end

  %w{ config log pids }.each do |f|
    it do should contain_file("/u/apps/my-app/shared/#{f}").with(
      :ensure  => 'directory',
      :owner   => 'my-app',
      :mode    => '0755',
      :require => 'File[/u/apps/my-app/shared]'
    ) end
  end

  it do should contain_file("/home/my-app/.ssh").with(
    :ensure  => 'directory',
    :mode    => '0700',
    :owner   => 'my-app',
    :require => 'User[my-app]'
  ) end

  it do should contain_file("/home/my-app/.ssh/authorized_keys").with(
    :ensure  => 'present',
    :owner   => 'my-app',
    :mode    => '0600',
    :content => '',
    :require => "File[/home/my-app/.ssh]"
  ) end

  context "when $ssh_key" do
    context "is string" do
      let(:params) { { :ssh_key => "ssh key" } }
      it do should contain_file("/home/my-app/.ssh/authorized_keys").with(
        :content => "ssh key"
      ) end
    end
    context "is array" do
      let(:params) { { :ssh_key => %w{ssh key} } }
      it do should contain_file("/home/my-app/.ssh/authorized_keys").with(
        :content => "ssh\nkey"
      ) end
    end
  end

  context "when $user" do
    let(:params) { { :user => 'my-user' } }
    it { should contain_user("my-user") }
    it { should contain_file("/home/my-user/.ssh") }
  end

  context "when $deploy_to" do
    let(:params) { { :deploy_to => '/my/path' } }

    it { should contain_file("/my/path") }
    %w{ shared current shared/config }.each do |f|
      it { should contain_file("/my/path/#{f}") }
    end
  end

  context "when $services" do
    let(:params) { { :services => true } }

    it do should contain_resource("Deploy::Runit[my-app]").with(
      :deploy_to => '/u/apps/my-app',
      :user      => 'my-app'
    ) end
  end

  context "when $server_name" do
    let(:params) { { :server_name => "example.com" } }
    it do should contain_resource("Deploy::Nginx[my-app]").with(
      :server_name => 'example.com',
      :deploy_to   => '/u/apps/my-app'
    ) end
  end
end
