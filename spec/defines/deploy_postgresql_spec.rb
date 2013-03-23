require 'spec_helper'

describe "deploy::postgresql" do
  let(:title) { 'my-user' }
  let(:facts) { { :postgres_default_version => '9.1', :osfamily => 'Debian' } }

  it do should contain_resource("Postgresql::Role[my-user]").with(
    :password_hash => /.+/,
    :superuser     => false,
    :require       => 'Class[Postgresql::Config]'
  ) end

  context "when $superuser is true" do
    let(:params) { { :superuser => true } }

    it do should contain_resource("Postgresql::Role[my-user]").with(
      :superuser     => true,
    ) end
  end

  context "when $superuser is false and $databases" do
    let(:params) { { :superuser => false, :databases => %w{ foo bar } } }


    it do should contain_resource("Postgresql::Database_grant[my-user]").with(
      :privilege => 'ALL',
      :db        => %w{ foo bar },
      :role      => 'my-user',
      :require   => %w{ Postgresql::Database_role[my-user]
                        Postgresql::Database[foo]
                        Postgresql::Database[bar] }
    ) end

  end
end
