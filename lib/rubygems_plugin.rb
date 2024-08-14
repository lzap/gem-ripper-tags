require 'rubygems/command_manager'
begin
  require 'rubygems/commands/ripper_tags_command'
rescue LoadError
  old_ruby = true
end

unless old_ruby
  Gem::CommandManager.instance.register_command :ripper_tags

  Gem.post_install do |installer|
    Gem::Commands::RipperTagsCommand.index(installer.spec, installer.ui, false, !ENV['RIPPER_TAGS_EMACS'].nil?, false)
  end
end
