require 'spec_helper'

describe "deploy" do

  it { should include_class("deploy::params") }
  it do should contain_exec("/bin/mkdir -p /u/apps").with(
    :creates => '/u/apps'
  ) end
end
