require 'spec_helper_system'

describe "Deploy Rabbitmq" do

  it 'should create regual user with vhost' do
    pp = <<-EOS
      class { 'deploy':
        rabbitmq => {
          foo => {
            password  => "pass",
            vhost     => "foo_db",
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
