if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
else
  require 'dotenv'
  Dotenv.load
end

require 'ping-pong'
use Ping::Pong

require_relative 'lib/server'
run Chefcard::Server
