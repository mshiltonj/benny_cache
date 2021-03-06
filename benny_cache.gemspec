# -*- encoding: utf-8 -*-
require File.expand_path('../lib/benny_cache/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Steven Hilton"]
  gem.email         = ["mshiltonj@gmail.com"]
  gem.description   = %q{A model caching library with indirect cached clearing}
  gem.summary       = %q{A model caching library with indirect cached clearing}
  gem.homepage      = "https://github.com/mshiltonj/benny_cache"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "benny_cache"
  gem.require_paths = ["lib"]
  gem.version       = BennyCache::VERSION


  gem.add_development_dependency('rspec')
  gem.add_development_dependency('mocha')
  gem.add_development_dependency('ZenTest')
  gem.add_development_dependency('simplecov')
end
