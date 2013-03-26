require 'spec_helper'

describe 'deploy_ssh_authorized_key_content()' do
  include WebMock::API

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("deploy_ssh_authorized_key_content")).to eq "function_deploy_ssh_authorized_key_content"
  end

  it "should raise Puppet::ParseError if args size 3" do
    expect{
      scope.function_deploy_ssh_authorized_key_content([1,2,3])
    }.to raise_error(Puppet::ParseError)
  end

  context "make content" do
    let(:data) { "key" }
    let(:options) { Hash.new }
    subject { scope.function_deploy_ssh_authorized_key_content([data, options]) }

    context "when just string" do
      it { should eq "key\n" }
    end

    context "when a array" do
      let(:data) { %w{ foo bar } }
      it { should eq "bar\nfoo\n" }
    end

    context "when github:// prefix" do
      let(:data) { "github://dima-exe" }
      before { mock_github }
      it { should eq "ssh key dima-exe@github\n" }

      def mock_github
        stub_request(:get, "https://api.github.com/users/dima-exe/keys").
          to_return(:status => 200, :body => %{[{"key": "ssh key"}]}, :headers => {})
      end
    end

    context "when options" do
      let(:options) { { :foo => "bar", :baz => "x" } }
      it { should eq "baz=x, foo=bar key\n" }
    end
  end
end

