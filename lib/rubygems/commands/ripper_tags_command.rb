require 'rubygems/command'
require 'tag_ripper'

class Gem::Commands::RipperTagsCommand < Gem::Command
  def initialize
    super 'ripper', 'Generate ctags for gems with Ruby/Ripper parser'
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

  def self.ctags(paths)
    # this bit is taken from ripper-tags/bin
    all_tags = []
    paths.each do |file|
      begin
        if File.directory?(file)
          Dir.foreach(file){ |f| paths << File.expand_path(File.join(file, f)) if f !~ /^\.\.?/ }
          next
        else
          next if file !~ /\.rb$/
          data = File.read(file)
        end
        sexp = TagRipper.new(data, file).parse
        v = TagRipper::Visitor.new(sexp, file, data)
        all_tags += v.tags
      rescue Exception => e
        #STDERR.puts "Skipping invalid file #{file}"
      end
    end

    File.open('tags', 'w') do |file|
      file.puts <<-EOC
!_TAG_FILE_FORMAT\t2\t/extended format; --format=1 will not append ;" to lines/
!_TAG_FILE_SORTED\t1\t/0=unsorted, 1=sorted, 2=foldcase/
      EOC

      all_tags.sort_by!{ |t| t[:name] }
      all_tags.each do |tag|
        kwargs = ''
        kwargs << "\tclass:#{tag[:class].gsub('::','.')}" if tag[:class]
        kwargs << "\tinherits:#{tag[:inherits].gsub('::','.')}" if tag[:inherits]

        kind = case tag[:kind]
               when 'method' then 'f'
               when 'singleton method' then 'F'
               when 'constant' then 'C'
               else tag[:kind].slice(0,1)
               end

        code = tag[:pattern].gsub('\\','\\\\\\\\').gsub('/','\\/')
        file.puts "%s\t%s\t/^%s$/;\"\t%c%s" % [tag[:name], tag[:path], code, kind, kwargs]
      end
    end
  end

  def self.index(spec)
    return unless File.directory?(spec.full_gem_path)

    Dir.chdir(spec.full_gem_path) do

      #if !(File.file?('tags') && File.read('tags', 1) == '!') && !File.directory?('tags')
      if !File.directory?('tags')
        yield "Generating ctags for #{spec.full_name}" if block_given?
        ctags(spec.require_paths.select { |p| File.directory?(p) })
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
