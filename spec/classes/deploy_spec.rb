require 'spec_helper'

describe "deploy" do
  let(:params) { Hash.new }

  it { should include_class("deploy::params") }
  it { should_not contain_exec("/bin/mkdir -p /u/apps") }

  context "when $users" do
    let(:params) { {
      :users => {
        "foo" => { "ensure" => "present" },
        "bar" => { "ensure" => "present" }
      }
    } }

    %w{ foo bar }.each do |u|
      it do should contain_resource("Deploy::User[#{u}]").with(
        :ensure  => 'present'
      ) end
    end
  end

  context "when $applications" do
    it { should contain_exec("/bin/mkdir -p /u/apps").with_creates("/u/apps") }

    let(:params) { {
      :applications => {
        "foo" => { "ensure" => "present" },
        "bar" => { "ensure" => "present" }
      }
    } }

    %w{ foo bar }.each do |u|
      it do should contain_resource("Deploy::Application[#{u}]").with(
        :ensure  => 'present',
        :require => 'Exec[/bin/mkdir -p /u/apps]'
      ) end
    end
  end

  context "when $rails" do
    it { should contain_exec("/bin/mkdir -p /u/apps").with_creates("/u/apps") }

    let(:params) { {
      :rails => {
        "foo" => { "ensure" => "present" },
        "bar" => { "ensure" => "present" }
      }
    } }

    %w{ foo bar }.each do |u|
      it do should contain_resource("Deploy::Rails[#{u}]").with(
        :ensure  => 'present',
        :require => 'Exec[/bin/mkdir -p /u/apps]'
      ) end
    end
  end

  context "when $mysql" do
    let(:facts) { {
      :osfamily => "Debian"
    } }

    let(:params) { {
      :mysql => {
        "foo" => { "ensure" => "present" },
        "bar" => { "ensure" => "present" }
      }
    } }

    %w{ foo bar }.each do |u|
      it do should contain_resource("Deploy::Mysql[#{u}]").with(
        :ensure => 'present'
      ) end
    end
  end

  context "when $postgresql" do
    let(:facts) { { :postgres_default_version => '9.1',
                    :osfamily                 => 'Debian',
                    :concat_basedir           => '/var/lib/puppet/concat'  } }
    let(:params) { {
      :postgresql => {
        "foo" => { "ensure" => "present" },
        "bar" => { "ensure" => "present" }
      }
    } }

    %w{ foo bar }.each do |u|
      it do should contain_resource("Deploy::Postgresql[#{u}]").with(
        :ensure => 'present'
      ) end
    end
  end
end
