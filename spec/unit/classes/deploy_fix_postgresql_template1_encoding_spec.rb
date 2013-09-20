require 'spec_helper'

describe "deploy::fix::postgresql_template1_encoding", :type => :class do
  let(:file) { '/var/lib/postgresql/fix_template1_encoding.sql' }

  it do should contain_file(file).with(
    :owner   => 'postgres',
    :content => /.+/,
    :require => 'Class[Postgresql::Config]'
  ) end

  it do should contain_exec("deploy::fix::postgresql_template1_encoding").with(
    :user    => 'postgres',
    :command => "/usr/bin/psql -f #{file}",
    :require => "File[#{file}]"
  ) end
end
