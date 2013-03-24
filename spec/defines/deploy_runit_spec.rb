require 'spec_helper'

describe "deploy::runit" do
  let(:title) { 'my-app' }

  it { should include_class("runit") }
  it { should include_class("deploy::params") }

  it do should contain_file("/u/apps/my-app/services").with(
    :ensure  => "directory",
    :owner   => 'my-app',
    :mode    => '0755',
    :require => 'File[/u/apps/my-app]'
  ) end

  it do should contain_resource("Runit::Service[my-app]").with(
    :user           => 'my-app',
    :rundir         => '/u/apps/my-app/services',
    :command        => 'runsvdir -P /u/apps/my-app/services',
    :finish_content => /.+/,
    :require        => 'File[/u/apps/my-app/services]'
  ) end

  context "with $user" do
    let(:params) { {:user => 'my-user'} }
    it do should contain_file("/u/apps/my-app/services").with(
      :owner   => 'my-user'
    ) end

    it do should contain_resource("Runit::Service[my-app]").with(
      :user    => 'my-user'
    ) end
  end

  context "with $deploy_to" do
    let(:params) { {:deploy_to => '/deploy/to'} }

    it { should contain_file("/deploy/to/services") }

    it do should contain_resource("Runit::Service[my-app]").with(
      :command => /\/deploy\/to/
    ) end
  end
end
