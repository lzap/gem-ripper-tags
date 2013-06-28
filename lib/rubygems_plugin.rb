require 'rubygems/command_manager'
begin
  require 'rubygems/commands/ripper_tags_command'
rescue LoadError => e
  old_ruby = true
end

unless old_ruby
  Gem::CommandManager.instance.register_command :ripper

  Gem.post_install do |installer|
    Gem::Commands::RipperTagsCommand.index(installer.spec)
  end
end
