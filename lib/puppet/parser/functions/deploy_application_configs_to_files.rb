require 'pp'

module Puppet::Parser::Functions
  newfunction(:deploy_application_configs_to_files, :type => :rvalue, :doc => <<-EOS
    Convert deploy::application::configs to files hash
  EOS
  ) do |args|
    args.length == 2 or raise Puppet::ParseError.new("deploy_application_configs_to_files takes 2 arguments!")

    path_prefix = args[0].to_s
    hash_to_convert = args[1]

    hash_to_convert.is_a?(Hash) or raise Puppet::ParseError.new("deploy_application_configs_to_files last agrument must be Hash, was #{hash_to_convert.inspect}")


    files_hash = {}

    hash_to_convert.each do |k,v|
      path = k.split("/")
      if path.size > 1
        files_hash["#{path_prefix}/#{path.first}"] = {
          :ensure => 'directory'
        }
      end
      value = case v
              when Hash
                v.to_yaml
              else
                v.to_s
              end
      files_hash["#{path_prefix}/#{path.join("/")}"] = {
        :content => value
      }
    end

    files_hash
  end
end

