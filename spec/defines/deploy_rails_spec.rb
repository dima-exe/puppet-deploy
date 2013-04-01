require 'spec_helper'

describe "deploy::rails" do
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
    :content => /#{Regexp.escape 'listen working_dir'}/
  ) end

  it do should contain_file("/u/apps/my-app/shared/config/puma.rb").with(
    :ensure  => 'present',
    :owner   => 'my-app',
    :mode    => '0640',
    :content => /#{Regexp.escape 'bind "unix://'}/
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
    let(:params) { { :server_name => "example.com a.example.com:80 b.example.com:8080" } }
    it { should include_class('nginx') }

    it { should contain_resource("Nginx::Site[my-app]") }

    context "setup server_name" do
      it do should contain_resource("Nginx::Site[my-app]").with(
        :content => /server_name a.example.com example.com;/
      ) end
    end

    context "setup upstream" do
      it do should contain_resource("Nginx::Site[my-app]").with(
        :content => /#{Regexp.escape 'server unix:/u/apps/my-app/shared/pids/web.sock'}/
      ) end
    end
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

    context "and $server_name" do
      let(:params) { {
        :server_name => "example.com",
        :listen_addr => "localhost:80"
      } }

      context "setup upstream" do
        it do should contain_resource("Nginx::Site[my-app]").with(
          :content => /#{Regexp.escape 'server localhost:80;'}/
        ) end
    end
    end
  end
end
