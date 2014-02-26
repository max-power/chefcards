require 'dotenv'
Dotenv.load

require_relative 'lib/server'
run Chefcard::Server
