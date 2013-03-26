require 'uri'
require 'net/http'
require 'json'

module Puppet::Parser::Functions
  newfunction(:deploy_ssh_authorized_key_content, :type => :rvalue, :doc => <<-EOS
    Get authorized_key content from string or array
  EOS
  ) do |args|
    args.length == 1 or raise Puppet::ParseError.new("deploy_application_configs_to_files takes 1 arguments!")

    keys = case args.first
           when Array
             args.first.map{|i| i.to_s}
           else
             [args.first.to_s]
           end

    keys.map do |key|
      if re = key.match(/^github\:\/\/(.*)$/)
        name = re[1]
        uri = URI("https://api.github.com/users/#{name}/keys")

        begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme == 'https'
          http.verify_mode = 0

          http.start do |h|
            res = h.request Net::HTTP::Get.new(uri.request_uri)
            json = JSON.load(res.body)
            json.first["key"] + " #{name}@github"
          end
        rescue Exception => _
          nil
        end
      else
        key
      end
    end.compact.sort.join("\n") + "\n"
  end
end

