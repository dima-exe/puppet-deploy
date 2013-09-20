require 'spec_helper'

describe "deploy::postgresql", :type => :define do
  let(:title) { 'my-user' }
  let(:facts) { { :postgres_default_version => '9.1',
                  :osfamily                 => 'Debian',
                  :concat_basedir           => '/var/lib/puppet/concat'  } }

  it { should include_class("postgresql::server") }
  it { should include_class("deploy::fix::postgresql_template1_encoding") }

  context "when $superuser is true" do
    let(:params) { { :superuser => true } }

    it do should contain_resource("Postgresql::Role[my-user]").with(
      :password_hash => /.+/,
      :superuser     => true,
      :require       => 'Class[Postgresql::Config]'
    ) end

    context "when $database" do
      let(:params) { { :superuser => true, :database => %w{ foo bar } } }
      %w{ foo bar }.each do |d|
        it do should contain_resource("Postgresql::Database[#{d}]").with(
          :locale  => "en_US.UTF-8",
          :require => 'Class[Postgresql::Config]'
        ) end
      end
    end
  end

  context "when $superuser is false and $databases" do
    let(:params) { { :superuser => false, :database => %w{ foo bar } } }

    %w{ foo bar }.each do |d|
      it do should contain_resource("Postgresql::Db[#{d}]").with(
        :grant    => 'all',
        :password => /.+/,
        :user     => 'my-user',
        :locale   => 'en_US.UTF-8',
        :require  => 'Class[Postgresql::Config]'
      ) end
    end

  end
end
