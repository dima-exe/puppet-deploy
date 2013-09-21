
require 'spec_helper_system'

describe "Deploy User" do

  after(:all) do
    pp = <<-EOS
      deploy::user { 'deploy':
        ensure => 'absent'
      }
    EOS
    puppet_apply(pp) do |r|
      r.exit_code.should_not == 1
    end
  end

  it 'should create user with ssh keys' do
    pp = <<-EOS
      class { 'deploy':
        users => {
          deploy => {
            ssh_key         => ["first", "last"],
            ssh_key_options => "key_options"
          }
        }
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should == 0
    end

    shell "id deploy" do |r|
      expect(r.exit_code).to eq 0
    end

    shell "cat /home/deploy/.ssh/authorized_keys" do |r|
      expect(r.stdout).to eq "key_options first\nkey_options last\n"
    end
  end

end
