require 'spec_helper_system'

describe "Deploy Rails" do

  after do
    pp = <<-EOS

    EOS
    puppet_apply(pp) do |r|
      r.exit_code.should_not == 1
    end
  end

  it 'should create rails app' do
    pp = <<-EOS
      class { 'deploy':
        rails => {
          app => {
            server_name => "example.com",
            ssh_key     => "foo",
            configs     => {
              'dir/example.conf' => 'content'
            },
            database_url => "mysql2://guest:guest@localhost/db_name?pool=50"
          }
        }
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should == 0
    end
  end

end
