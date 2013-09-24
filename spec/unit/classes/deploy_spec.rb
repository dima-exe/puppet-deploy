require 'spec_helper'

describe "deploy", :type => :class do
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

  context "when $mongodb" do
    let(:facts) { {
      :osfamily => "debian"
    } }
    let(:params) { {
      :mongodb => {
        "foo" => { "ensure" => "present" },
        "bar" => { "ensure" => "present" }
      }
    } }

    %w{ foo bar }.each do |u|
      it do should contain_resource("Deploy::Mongodb[#{u}]").with(
        :ensure => 'present'
      ) end
    end
  end

  context "when $sites" do
    let(:params) { {
      :sites => {
        "foo" => {
          "document_root" => "document_root",
          "server_name"   => "server_name"
        },
      }
    } }

    %w{ foo }.each do |u|
      it do should contain_resource("Deploy::Nginx::Site[#{u}]").with(
        :document_root => 'document_root',
        :server_name   => "server_name"
      ) end
    end
  end

  context "when $services" do
    let(:params) { {
      :services => {
        "foo" => {
          "rundir"  => "/run/dir",
          "command" => "command"
        },
        "bar" => {
          "rundir"  => "/run/dir",
          "command" => "command"
        },
      }
    } }

    %w{ foo }.each do |u|
      it do should contain_resource("Deploy::Runit::Service[#{u}]").with(
        :rundir  => '/run/dir',
        :command => "command"
      ) end
    end
  end
end
