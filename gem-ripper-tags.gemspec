# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "gem-ripper-tags"
  s.version     = "1.2.1"
  s.authors     = ["Tim Pope", "Lukas Zapletal"]
  s.email       = ["code@tpop"+'e.net', "lzap+rpm@red"+'hat.com']
  s.homepage    = "https://github.com/lzap/gem-ripper-tags"
  s.summary     = %q{fast and accurate ctags generator on gem install}
  s.license     = 'MIT'

  s.files         = Dir['lib/**/*', 'MIT-LICENSE', 'README.markdown', 'Rakefile']
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'ripper-tags', '>= 0.1.2'
  s.add_development_dependency 'rake'
end
