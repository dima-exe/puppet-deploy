
require 'spec_helper_system'

describe "Deploy User" do

  after do
    pp = <<-EOS
      deploy::nginx::site { 'site':
        server_name   => "example.com",
        document_root => "/tmp",
        ensure        => 'absent'
      }
    EOS
    puppet_apply(pp) do |r|
      r.exit_code.should_not == 1
    end
  end

  it 'should create nginx site with upstream and is_rails' do
    pp = <<-EOS
      class { 'deploy':
        sites => {
          site => {
            document_root => "/tmp",
            server_name   => "example.com",
            upstream      => "127.0.0.1:3000",
            is_rails      => true
          }
        }
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should == 0
    end

    shell "nginx -t" do |r|
      expect(r.exit_code).to eq 0
    end
  end

  it 'should create nginx site' do
    pp = <<-EOS
      class { 'deploy':
        sites => {
          site => {
            document_root => "/tmp",
            server_name   => "example.com",
          }
        }
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should == 0
    end

    shell "nginx -t" do |r|
      expect(r.exit_code).to eq 0
    end
  end

  it 'should create nginx site with auth_basic' do
    pp = <<-EOS
      class { 'deploy':
        sites => {
          site => {
            document_root => "/tmp",
            server_name   => "example.com",
            auth_basic    => ['foo:bar']
          }
        }
      }
    EOS

    puppet_apply(pp) do |r|

      r.exit_code.should == 2
      r.refresh
      r.exit_code.should == 0
    end

    shell "nginx -t" do |r|
      expect(r.exit_code).to eq 0
    end
  end

end
