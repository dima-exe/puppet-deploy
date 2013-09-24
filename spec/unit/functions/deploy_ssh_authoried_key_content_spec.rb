require 'spec_helper'
require 'fileutils'

describe 'deploy_ssh_authorized_key_content()', :type => :function do
  include WebMock::API

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("deploy_ssh_authorized_key_content")).to eq "function_deploy_ssh_authorized_key_content"
  end

  it "should raise Puppet::ParseError if args size != 2" do
    expect{
      scope.function_deploy_ssh_authorized_key_content([nil])
    }.to raise_error(Puppet::ParseError)
  end

  context "make content" do
    let(:data)    { "key" }
    let(:options) { { "cache_path" => '/tmp' } }
    subject { scope.function_deploy_ssh_authorized_key_content([data, options]) }

    context "when $key is string" do
      it { should eq "key\n" }
    end

    context "when $key is array" do
      let(:data) { %w{ foo bar } }
      it { should eq "bar\nfoo\n" }
    end

    context "when evrone:// prefix" do
      let(:key) { "ssh key dima@evrone.ru\n" }
      let(:data) { "evrone://dima" }
      let(:file) { '/tmp/evrone.keys' }
      let(:options) { {
        'cache_path' => "/tmp",
        'evrone_keys_path' => file
      } }

      context "when keys file exists" do
        after do
          FileUtils.rm_f(file)
        end

        before do
          FileUtils.rm_f(file)
          File.open(file, 'w') do |io|
            io.write({"dima" => key}.to_json)
          end
        end
        it { should eq key }
      end

      context "when keys file does not exists" do
        before do
          FileUtils.rm_f(file)
        end

        it { should eq "\n" }
      end

    end

    context "when github:// prefix" do
      let(:key) { "ssh key dima-exe@github\n" }
      let(:data) { "github://dima-exe" }
      before { mock_github }

      it { should eq key }

      context "should store key in cache" do
        subject { File.read("/tmp/dima-exe.key") }
        it { should eq key.strip }
        after { FileUtils.rm_f '/tmp/dima-exe.key' }
      end

      context "should use cached version if request is failed" do
        before do
          File.open('/tmp/dima-exe.key', 'w') {|io| io.write key.strip }
          mock_failed_github
        end
        it { should eq key }
        after do
          FileUtils.rm_f '/tmp/dima-exe.key'
        end
      end

      context "should be empty if first request failed" do
        before do
          mock_failed_github
        end
        it { should eq "\n" }
      end

      def mock_github
        stub_request(:get, "https://github.com/dima-exe.keys").
          to_return(:status => 200, :body => %{ssh key2\nssh key}, :headers => {})
      end

      def mock_failed_github
        stub_request(:get, "https://github.com/dima-exe.keys").
          to_return(:status => 404, :body => '', :headers => {})
      end
    end

    context "when key options" do
      let(:options) { { "cache_path" => '/tmp', "key_options" => 'foo=bar' } }
      it { should eq "foo=bar key\n" }
    end
  end
end

