require 'json'
require 'net/http'
require 'net/https'

module Puppet::Parser::Functions
  newfunction(:deploy_ssh_authorized_key_content, :type => :rvalue, :doc => <<-EOS
    Get authorized_key content from string or array
  EOS
  ) do |args|

    github_http = lambda do
      @github_http ||= begin
        http = Net::HTTP.new("github.com", 443)
        http.use_ssl = true
        http.verify_mode = 0
        http
      end
    end

    keys_to_array = lambda do |keys|
      case keys
      when Array
        args.first.map{|i| i.to_s}
      else
        [keys.to_s]
      end
    end

    cache_save = lambda do |path, name, key|
      fname = File.join(path, "#{name}.key")
      begin
        File.open fname, 'w' do |io|
          io.write key
        end
      rescue Exception => _
        raise Puppet::ParseError, "Could not write cache data to cache at #{fname}"
      end
    end

    cache_get = lambda do |path, name, key|
      fname = File.join(path, "#{name}.key")
      if File.readable?(fname)
        File.read fname
      end
    end

    download_github_key = lambda do |name|
      begin
        github_http.call.start do |http|
          res = http.request Net::HTTP::Get.new("/#{name}.keys")
          res = res.body.split("\n").last
          res + " #{name}@github"
        end
      rescue Exception => e
        Puppet.notice "Github key fail: #{e.inspect}"
        nil
      end
    end

    args.length == 2 or
      raise Puppet::ParseError.new("deploy_application_configs_to_files takes 2 arguments")

    args.last.is_a?(Hash) or
      raise Puppet::ParseError.new("deploy_application_configs_to_files last params must be Hash")

    options = args.last
    keys = keys_to_array.call(args.first)

    cache_path = options["cache_path"]
    key_options = options["key_options"]
    key_options = nil if key_options == :undef

    unless cache_path && File.directory?(cache_path)
      raise Puppet::ParseError, "Please set :cache_path in options"
    end

    keys.map do |key|
      if re = key.match(/^github\:\/\/(.*)$/)
        name = re[1]
        key = download_github_key.call(name)
        if key
          cache_save.call(cache_path, name, key)
        else
          key = cache_get.call(cache_path, name, key)
        end
        key
      else
        key
      end
    end.compact.sort.map do |key|
      if key_options
        key = "#{key_options.to_s} #{key}"
      end
      key
    end.join("\n") + "\n"
  end
end

