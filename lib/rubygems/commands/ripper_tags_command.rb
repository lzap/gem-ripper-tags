require 'rubygems/command'
require 'ripper-tags'

class Gem::Commands::RipperTagsCommand < Gem::Command
  def initialize
    super 'ripper_tags', 'Generate ctags for gems with Ruby/Ripper parser'
    
    add_option("--emacs", "Generate Emacs TAGS instead Vim tags") do |value, options|
      options[:emacs] = true
    end
    add_option("--reindex", "Reindex all tags again") do |value, options|
      options[:reindex] = true
    end
    add_option("--debug", "Enable debugging output") do |value, options|
      options[:debug] = true
    end
  end

  def execute
    if Gem::Specification.respond_to?(:each)
      Gem::Specification
    else
      Gem.source_index.gems.values
    end.each do |spec|
      self.class.index(spec, ui, options[:reindex], options[:emacs], options[:debug])
    end
  rescue Exception => e
    if options[:debug] || ENV['RIPPER_TAGS_DEBUG']
      puts e.message
      puts e.backtrace.join("\n")
    end
    raise e
  end

  def self.index(spec, ui, reindex, emacs, debug)
    if emacs
      tag_filename = 'TAGS'
      format = "emacs"
    else
      tag_filename = 'tags'
      format = "vim"
    end

    return unless File.directory?(spec.full_gem_path)
    tag_file = File.join(spec.full_gem_path, tag_filename)

    if (!File.directory?(tag_filename) && reindex) || (!File.file?(tag_filename) && !File.directory?(tag_filename))
      ui.say "Ripper is generating ctags for #{spec.full_name}"
      riopt = RipperTags.default_options
      riopt.tag_relative = "always"
      riopt.tag_file_name = tag_file
      riopt.format = format
      riopt.recursive = true
      riopt.force = true
      riopt.files = [spec.full_gem_path]
      RipperTags.run riopt
    end

    target = 'lib/bundler/cli.rb'
    if File.writable?(target) && !File.read(target).include?('load_plugins')
      ui.say "Injecting gem-ripper-tags into #{spec.full_name}"
      File.open(target, 'a') do |f|
        f.write "\nGem.load_plugins rescue nil\n"
      end
    end
  rescue Errno::EACCES
    ui.say "Ripper cannot write to #{tag_file}"
  rescue => e
    raise unless ui
    ui.say "Failed processing ctags for #{spec.full_name} (#{e.class})"
    if debug
      ui.say e
    end
  end
end
