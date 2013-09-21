source 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION'] ? "~> #{ENV['PUPPET_GEM_VERSION']}" : '~> 3.2.0'

gem 'rake'
gem 'puppet', puppetversion, :require => false
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'
gem 'rspec-system-puppet'
gem 'webmock'

group :development do
  gem 'puppet-blacksmith'
end
