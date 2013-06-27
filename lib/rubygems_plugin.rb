require 'rubygems/command_manager'
require 'rubygems/commands/ripper_tags_command'

Gem::CommandManager.instance.register_command :ripper

Gem.post_install do |installer|
  Gem::Commands::RipperTagsCommand.index(installer.spec)
end
