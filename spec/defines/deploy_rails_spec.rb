require 'spec_helper'

describe "deploy::rails" do
  let(:title) { 'my-app' }

  it do should contain_resource("Deploy::Application[my-app]").with(
    :ensure    => "present",
    :user      => 'my-app',
    :ssh_key   => nil,
    :deploy_to => '/u/apps/my-app',
    :services  => false,
    :configs   => nil
  ) end

  it { should_not contain_file("/u/apps/my-app/shared/config/database.yml") }
  it { should_not contain_file("/u/apps/my-app/shared/config/resque.yml") }

  it do should contain_file("/u/apps/my-app/shared/config/unicorn.rb").with(
    :ensure  => 'present',
    :owner   => 'my-app',
    :mode    => '0640',
    :content => /num_workers = 2/
  ) end

  context "when $database_url" do
    let(:file) { '/u/apps/my-app/shared/config/database.yml' }
    let(:url) { 'postgres://user:password@host/database?param=value'  }
    let(:params) { { :database_url => url } }

    it do should contain_file(file).with(
      :ensure  => 'present',
      :owner   => 'my-app',
      :mode    => '0640'
    ) end

    context "save scheme" do
      it do should contain_file(file).with(
        :content => /  adapter: "postgres"\n/
      ) end
    end

    context "save host" do
      it do should contain_file(file).with(
        :content => /  host: "host"\n/
      ) end
    end

    context "save username" do
      it do should contain_file(file).with(
        :content => /  host: "host"\n/
      ) end
    end

    context "save password" do
      it do should contain_file(file).with(
        :content => /  password: "password"\n/
      ) end
    end

    context "save query params" do
      it do should contain_file(file).with(
        :content => /  param: "value"\n/
      ) end
    end

    context "save database" do
      it do should contain_file(file).with(
        :content => /  database: "database"\n/
      ) end
    end

    context "default values" do
      let(:url) { 'postgres:///' }

      context "save host" do
        it do should contain_file(file).with(
          :content => /  host: "localhost"\n/
        ) end
      end

      context "save username" do
        it do should contain_file(file).with(
          :content => /  username: "my-app"\n/
        ) end
      end

      context "save password" do
        it do should contain_file(file).with(
          :content => /  password: "my-app"\n/
        ) end
      end

      context "save database" do
        it do should contain_file(file).with(
          :content => /  database: "my_app_production"\n/
        ) end
      end
    end
  end

  context "when $services is true" do
    let(:params) { { :services => true } }
    it do should contain_resource("Deploy::Application[my-app]").with(
      :services => true
    ) end
  end

  context "when $server_name" do
    let(:params) { { :server_name => 'example.com' } }
    it do should contain_resource("Deploy::Application[my-app]").with(
      :server_name => 'example.com'
    ) end
  end

  context "when $configs" do
    let(:params) { { :configs => { "file" => "value" } } }

    it do should contain_resource("Deploy::Application[my-app]").with(
      :configs => {"file" => "value"}
    ) end
  end
end
