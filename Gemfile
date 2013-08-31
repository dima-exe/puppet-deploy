source 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION'] ? "~> #{ENV['PUPPET_GEM_VERSION']}" : '~> 3.2'
puts puppetversion.inspect

gem 'rake'
gem 'puppet', puppetversion, :require => false
gem 'puppet-lint'
gem 'puppetlabs_spec_helper', :require => false
gem 'webmock'
