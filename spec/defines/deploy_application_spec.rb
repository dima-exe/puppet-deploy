require 'spec_helper'

describe "deploy::application" do
  let(:title) { 'my-app' }

  it { should include_class('deploy::params') }

  it do should contain_resource('Deploy::User[my-app]').with(
    :ssh_key         => nil,
    :ssh_key_options => nil
  ) end

  it do should contain_file('/u/apps/my-app').with(
    :ensure => 'directory',
    :owner  => 'my-app',
    :mode   => '0775',
    :require => 'User[my-app]'
  ) end

  %w{ shared }.each do |f|
    it do should contain_file("/u/apps/my-app/#{f}").with(
      :ensure  => 'directory',
      :owner   => 'my-app',
      :mode    => '0775',
      :require => 'File[/u/apps/my-app]'
    ) end
  end

  %w{ config log pids }.each do |f|
    it do should contain_file("/u/apps/my-app/shared/#{f}").with(
      :ensure  => 'directory',
      :owner   => 'my-app',
      :mode    => '0775',
      :require => 'File[/u/apps/my-app/shared]'
    ) end
  end

  context "when $ssh_key" do
    let(:params) { { :ssh_key => "ssh key" } }
    it do should contain_resource("Deploy::User[my-app]").with(
      :ssh_key => 'ssh key'
    ) end
  end

  context "when $ssh_key_options" do
    let(:params) { { :ssh_key_options => "ssh key options" } }
    it do should contain_resource("Deploy::User[my-app]").with(
      :ssh_key_options => 'ssh key options'
    ) end
  end

  context "when $user" do
    let(:params) { { :user => 'my-user' } }
    it { should contain_user("my-user") }
    it { should contain_resource("Deploy::User[my-user]") }
  end

  context "when $deploy_to" do
    let(:params) { { :deploy_to => '/my/path' } }

    it { should contain_file("/my/path") }
    %w{ shared shared/config }.each do |f|
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

  context "when $configs" do
    let(:params) { {
      :configs => {
        "resque.yml" => "yaml",
        "settings/production.yml" => {
          "name" => "value"
        }
      }
    } }

    it { should be }
  end
end
