require 'rubygems/command'
require 'ripper-tags'

class Gem::Commands::RipperTagsCommand < Gem::Command
  def initialize
    super 'ripper_tags', 'Generate ctags for gems with Ruby/Ripper parser'
  end

  def execute
    if Gem::Specification.respond_to?(:each)
      Gem::Specification
    else
      Gem.source_index.gems.values
    end.each do |spec|
      self.class.index(spec) do |message|
        say message
      end
    end
  end

  def self.index(spec)
    return unless File.directory?(spec.full_gem_path)

    Dir.chdir(spec.full_gem_path) do

      # TODO support for full regeneration via param (+ emacs)
      # http://rubygems.rubyforge.org/rubygems-update/Gem/CommandManager.html
      #if !File.directory?('tags')
      if !(File.file?('tags') && File.read('tags', 1) == '!') && !File.directory?('tags')
        yield "Ripper is generating ctags for #{spec.full_name}" if block_given?
        options = RipperTags.default_options
        options.format = "vim"
        options.recursive = true
        options.force = true
        RipperTags.run options
      end

      target = 'lib/bundler/cli.rb'
      if File.writable?(target) && !File.read(target).include?('load_plugins')
        yield "Injecting gem-ripper-tags into #{spec.full_name}" if block_given?
        File.open(target, 'a') do |f|
          f.write "\nGem.load_plugins rescue nil\n"
        end
      end

    end
  end
end
