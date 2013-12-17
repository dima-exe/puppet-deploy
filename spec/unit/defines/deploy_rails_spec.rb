require 'spec_helper'

describe "deploy::rails", :type => :define do
  let(:title) { 'my-app' }

  it do should contain_resource("Deploy::Application[my-app]").with(
    :ensure          => "present",
    :user            => 'my-app',
    :ssh_key         => nil,
    :ssh_key_options => nil,
    :deploy_to       => '/u/apps/my-app',
    :supervisor      => nil,
    :configs         => nil
  ) end

  it { should_not contain_file("/u/apps/my-app/shared/config/database.yml") }
  it { should_not contain_file("/u/apps/my-app/shared/config/resque.yml") }

  it do should contain_file("/u/apps/my-app/shared/config/unicorn.rb").with(
    :ensure  => 'present',
    :owner   => 'my-app',
    :mode    => '0640',
    :content => /#{Regexp.escape 'listen "127.0.0.1:3000"'}/
  ) end

  it do should contain_file("/u/apps/my-app/shared/config/puma.rb").with(
    :ensure  => 'present',
    :owner   => 'my-app',
    :mode    => '0640',
    :content => /#{Regexp.escape 'bind "tcp://127.0.0.1:3000"'}/
  ) end

  context "when $puma_threads" do
    let(:params) { { :puma_threads => "0,16" } }

    it do should contain_file("/u/apps/my-app/shared/config/puma.rb").with(
      :content => /threads 0,16/
    ) end
  end

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

  context "when $supervisor" do
    let(:params) { { :supervisor => true } }
    it do should contain_resource("Deploy::Application[my-app]").with(
      :supervisor => true
    ) end
  end

  context "when $configs" do
    let(:params) { { :configs => { "file" => "value" } } }

    it do should contain_resource("Deploy::Application[my-app]").with(
      :configs => {"file" => "value"}
    ) end
  end

  [:ssh_key, :ssh_key_options].each do |k|
    context "when $#{k}" do
      let(:params) { { k => k.to_s } }
      it do should contain_resource("Deploy::Application[my-app]").with(
        k => k.to_s
      ) end
    end
  end

  context "with $server_name" do
    let(:params) { {
      :server_name  => "example.com",
      :ssl_cert     => 'ssl cert',
      :ssl_cert_key => "ssl cert key"
    } }

    it do should contain_resource("Deploy::Nginx::Site[my-app]").with(
      :ensure        => 'present',
      :server_name   => "example.com",
      :upstream      => "127.0.0.1:3000",
      :document_root => "/u/apps/my-app/current/public",
      :ssl_cert      => "ssl cert",
      :ssl_cert_key  => 'ssl cert key'
    ) end
  end

  context "when $listen_addr" do
    let(:params) { { :listen_addr => 'localhost:80' } }

    it do should contain_file("/u/apps/my-app/shared/config/unicorn.rb").with(
      :ensure  => 'present',
      :owner   => 'my-app',
      :mode    => '0640',
      :content => /#{Regexp.escape 'listen "localhost:80"'}/
    ) end

    it do should contain_file("/u/apps/my-app/shared/config/puma.rb").with(
      :ensure  => 'present',
      :owner   => 'my-app',
      :mode    => '0640',
      :content => /#{Regexp.escape 'bind "tcp://localhost:80"'}/
    ) end

  end
end
