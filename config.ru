if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
else
  require 'dotenv'
  Dotenv.load
end

require_relative 'lib/server'
run Chefcard::Server
