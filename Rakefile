$:.unshift(File.join(File.dirname(__FILE__), 'lib')).uniq!

begin
  require "bundler/gem_tasks"
rescue LoadError
end

task :default do
  require 'rubygems/commands/ripper_tags_command'
  Gem::Commands::RipperTagsCommand.new.execute
end
