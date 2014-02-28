require 'dotenv/tasks' if ENV["RACK_ENV"] == "development"

desc "Run console"
task :console do
  require 'irb'
  require 'irb/completion'
  require 'passbook'
  require_relative 'lib/server'
  ARGV.clear
  IRB.start
end