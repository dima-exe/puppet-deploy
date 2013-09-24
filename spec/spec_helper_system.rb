require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  # Project root for the firewall code
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  # Puppet helpers
  c.include RSpecSystemPuppet::Helpers
  c.extend RSpecSystemPuppet::Helpers

  c.before :suite do
    # Install puppet
    puppet_install

    # Copy this module into the module path of the test node
    puppet_module_install(:source => proj_root, :module_name => 'deploy')
    shell('puppet module install puppetlabs/postgresql --version 2.5.0')
    shell('puppet module install puppetlabs/mysql --version 0.9.0')
    shell('puppet module install steakknife/runit --version 0.1.1')
    shell("curl https://codeload.github.com/BenoitCattie/puppet-nginx/tar.gz/master -o /tmp/nginx.tgz")
    shell("tar -vzxf /tmp/nginx.tgz -C /etc/puppet/modules")
    shell("mv /etc/puppet/modules/puppet-nginx-master /etc/puppet/modules/nginx")
  end
end
