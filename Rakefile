require 'dotenv/tasks'

desc "Run console"
task :console do
  require 'irb'
  require 'irb/completion'
  require 'passbook'
  require_relative 'lib/server'
  ARGV.clear
  IRB.start
end