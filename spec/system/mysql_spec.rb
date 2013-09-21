require 'spec_helper_system'

describe "Deploy Mysql" do

  after(:all) do
    puppet_apply("class { 'mysql::server': ensure => absent }") do |r|
      r.exit_code.should_not == 1
    end
  end

  it 'should create regual user with database' do
    pp = <<-EOS
      class { 'deploy':
        mysql => {
          foo => {
            password  => "pass",
            database  => "foo_db",
            superuser => false
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

  it 'should create super user without database' do
    pp = <<-EOS
      class { 'deploy':
        mysql => {
          foo => {
            password  => "pass",
            superuser => true
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
