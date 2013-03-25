require 'spec_helper'

describe 'deploy_application_configs_to_files()' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  let(:data) { {
    "resque.yml" => {
      "content" => "production: localhost/0\n"
    },
    "settings/production.yml" => {
      "content" => {
        "name" => "value"
      }
    }
  } }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("deploy_application_configs_to_files")).to eq "function_deploy_application_configs_to_files"
  end

  it "should raise Puppet::ParseError if args size != 2" do
    expect{
      scope.function_deploy_application_configs_to_files([1])
    }.to raise_error(Puppet::ParseError)
  end

  it "should raise ArgumentError last arg is not Hash" do
    expect{
      scope.function_deploy_application_configs_to_files("prefix", "prefix")
    }.to raise_error(ArgumentError)
  end

  context "convert hash" do
    let(:data) { Hash.new }
    subject { scope.function_deploy_application_configs_to_files(["/prefix", data]).to_a.sort }

    context "when just file and value" do
      let(:data) { { "resque.yml" => "yaml" } }
      let(:exp)  { [
        ["/prefix/resque.yml", { :content => "yaml" } ]
      ] }
      it { should eq exp }
    end

    context "when directory and file" do
      let(:data) { { "dir/resque.yml" => "yaml" } }
      let(:exp)  { [
        ["/prefix/dir", {:ensure => "directory"}],
        ["/prefix/dir/resque.yml", { :content => "yaml" }]
      ] }
      it { should eq exp }
    end
  end
end

