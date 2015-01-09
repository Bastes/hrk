require 'bundler'
Bundler.require
require 'rubygems/tasks'

Gem::Tasks.new

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end
