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
    shell('puppet module install puppetlabs/postgresql')
  end
end
