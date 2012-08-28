# -*- encoding: utf-8 -*-
require File.expand_path('../lib/benny_cache/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Steven Hilton"]
  gem.email         = ["mshiltonj@gmail.com"]
  gem.description   = %q{A caching library}
  gem.summary       = %q{A caching library}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "benny_cache"
  gem.require_paths = ["lib"]
  gem.version       = BennyCache::VERSION
end
