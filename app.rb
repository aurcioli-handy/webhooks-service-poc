require 'sinatra'
require 'yaml'
require 'pry'
require 'rack/proxy'

#0. Load environment variables
begin
  env_vars_content = File.read('./config/application.yml')
  env_vars = YAML.load(env_vars_content)
rescue => e
  puts "WARNING Environment Variables may not be loaded."
  env_vars = false
end
if env_vars
  env_vars.each do |key, value|
    ENV[key] ||= value.to_s
  end
end

#1. Load all authentication modules
Dir.glob('./authentication_modules/*.rb').each do |file|
  require file
end

#2. Load webhook definitions
routes = YAML.load_file('webhooks.yaml')

#3. Generate all webhook routes
routes.each do |url, definition|
  endpoint_url = url.to_s

  definition.each do |d|
    method = d["method"]
    callback = d["callback"]
    authentication = d["authentication"]

    send(method, endpoint_url) do
      authentication_app = AuthenticationModules.const_get(authentication)
      if authentication_app.authentic?(request)
        proxy = Rack::Proxy.new({backend: callback})
        proxy.call(env)
      else
        halt(401, "Unauthorized")
      end
    end

  end
  
end

