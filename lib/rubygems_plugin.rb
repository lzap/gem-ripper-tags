require 'rubygems/command_manager'
begin
  require 'rubygems/commands/ripper_tags_command'
rescue LoadError => e
  old_ruby = true
end

unless old_ruby
  Gem::CommandManager.instance.register_command :ripper_tags

  Gem.post_install do |installer|
    Gem::Commands::RipperTagsCommand.index(installer.spec, false, !ENV['RIPPER_TAGS_EMACS'].nil?)
  end
end
