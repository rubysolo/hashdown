# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hashdown/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Solomon White"]
  gem.email         = ["rubysolo@gmail.com"]
  gem.description   = %q{Hashdown}
  gem.summary       = %q{super lightweight Rails plugin that adds hash-style lookups and option list (for generating dropdowns) to ActiveRecord models}
  gem.homepage      = "https://github.com/rubysolo/hashdown"

  gem.add_dependency 'activerecord', '~> 3.0'

  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sqlite3'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hashdown"
  gem.require_paths = ["lib"]
  gem.version       = Hashdown::VERSION
end
