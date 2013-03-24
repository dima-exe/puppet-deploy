require 'spec_helper'

describe "deploy::mysql" do
  let(:title) { 'my-user' }

  it do should contain_resource("Database_user[my-user@localhost]").with(
    :password_hash => /.*/,
    :provider      => 'mysql',
    :require       => 'Class[Mysql::Config]'
  ) end

  context "when $superuser is true" do
    let(:params) { { :superuser => true } }

    it do should contain_resource("Database_grant[my-user@localhost]").with(
      :privileges => %w{ all },
      :require    => 'Database_user[my-user@localhost]'
    ) end
  end

  context "when $database" do
    let(:params) { { :database => %w{ foo bar } } }

    %w{ foo bar }.each do |d|
      it do should contain_resource("Database[#{d}]").with(
        :ensure  => 'present',
        :require => 'Database_user[my-user@localhost]'
      ) end
    end

    context "when $create_database is false" do
      let(:params) { { :database => %w{ foo bar }, :create_database => false } }

      %w{ foo bar }.each do |d|
        it { should_not contain_resource("Database[#{d}]") }
      end
    end
  end

  context "when $superuser is false and databases" do
    let(:params) { { :superuser => false, :database => %w{ foo bar } } }

    %w{ foo bar }.each do |d|
      it do should contain_resource("Database_grant[my-user@localhost/#{d}]").with(
        :privileges => %w{ all },
        :require    => 'Database_user[my-user@localhost]'
      ) end
    end
  end

  context "when $host" do
    let(:params) { { :host => "host" } }
    it { should contain_resource("Database_user[my-user@host]") }
  end
end
