require 'spec_helper_system'

describe "Deploy Services" do

  after do
    pp = <<-EOS
      deploy::runit::service { "app":
        rundir  => '/tmp',
        command => '/bin/true',
        ensure  => 'absent'
      }
    EOS
    puppet_apply(pp) do |r|
      r.exit_code.should_not == 1
    end
  end

  it 'should create rails app' do
    pp = <<-EOS
      Apt::Source['Evrone'] -> Package <| |>
      apt::source{ 'Evrone':
        location    => 'http://download.opensuse.org/repositories/home:/dmexe/xUbuntu_12.04/',
        repos       => './',
        release     => '',
        include_src => false,
        key         => '1024D/4CFF08F2',
        key_source  => 'http://download.opensuse.org/repositories/home:/dmexe/xUbuntu_12.04/Release.key',
      }
      class { 'deploy':
        services    => {
          app       => {
            rundir  => '/tmp',
            command => '/bin/true'
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
