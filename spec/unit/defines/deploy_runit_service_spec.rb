require 'spec_helper'

describe "deploy::runit::service", :type => :define do
  let(:title) { 'my-app' }
  let(:default_params) { { :command => "command", :rundir => "/run/dir" } }
  let(:params) { default_params }

  it { should include_class("runit") }

  it do should contain_resource("Runit::Service[my-app]").with(
    :user    => 'my-app',
    :rundir  => '/run/dir',
    :command => 'command',
    :logger  => true,
    :ensure  => "present"
  ) end

  context "with $user" do
    let(:params) { default_params.merge(:user => 'user') }

    it do should contain_resource("Runit::Service[my-app]").with(
      :user => 'user'
    ) end
  end
end
