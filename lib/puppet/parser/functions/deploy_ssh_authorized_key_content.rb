require 'uri'
require 'net/http'
require 'json'

module Puppet::Parser::Functions
  newfunction(:deploy_ssh_authorized_key_content, :type => :rvalue, :doc => <<-EOS
    Get authorized_key content from string or array
  EOS
  ) do |args|
    (args.length == 1 || args.length == 2) or
      raise Puppet::ParseError.new("deploy_application_configs_to_files takes 1 arguments!")

    options = args[1].to_s.strip
    keys = case args.first
           when Array
             args.first.map{|i| i.to_s}
           else
             [args.first.to_s]
           end

    http = Net::HTTP.new("api.github.com", 443)
    http.use_ssl = true
    http.verify_mode = 0

    keys.map do |key|
      if re = key.match(/^github\:\/\/(.*)$/)
        name = re[1]
        uri = URI("https://api.github.com/users/#{name}/keys")
        begin
          http.start do |h|
            res = h.request Net::HTTP::Get.new(uri.request_uri)
            json = JSON.load(res.body)
            json.first["key"] + " #{name}@github"
          end
        rescue Exception => e
          raise e
        end
      else
        key
      end
    end.compact.sort.map do |key|
      unless options == ''
        key = "#{options} #{key}"
      end
      key
    end.join("\n") + "\n"
  end
end

