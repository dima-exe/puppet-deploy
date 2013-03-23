require 'spec_helper'

describe "deploy::mysql" do
  let(:title) { 'my-user' }

  it do should contain_resource("Database_user[my-user]").with(
    :password_hash => /.*/,
    :provider      => 'mysql',
    :require       => 'Class[Mysql::Config]'
  ) end

  context "when $superuser is true" do
    let(:params) { { :superuser => true } }

    it do should contain_resource("Database_grant[my-user]").with(
      :privileges => %w{ all },
      :require    => 'Database_user[my-user]'
    ) end
  end

  context "when $superuser is false and databases" do
    let(:params) { { :superuser => false, :databases => %w{ foo bar } } }

    %w{ foo bar }.each do |d|
      it do should contain_resource("Database_grant[my-user/#{d}]").with(
        :privileges => %w{ all },
        :require    => 'Database_user[my-user]'
      ) end
    end

  end
end
