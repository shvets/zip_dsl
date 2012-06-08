# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/lib/zip_dsl/version')

Gem::Specification.new do |spec|
  spec.name          = "zip_dsl"
  spec.summary       = %q{Library for working with zip file in DSL-way }
  spec.description   = %q{Library for working with zip file in DSL-way }
  spec.email         = "alexander.shvets@gmail.com"
  spec.authors       = ["Alexander Shvets"]
  spec.homepage      = "http://github.com/shvets/zip_dsl"

  spec.files         = `git ls-files`.split($\)
  #spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  #gemspec.bindir = "bin"
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.version       = ZipDSL::VERSION

  spec.add_runtime_dependency "meta_methods", [">= 0"]
  spec.add_development_dependency "gemspec_deps_gen", [">= 0"]
  spec.add_development_dependency "gemcutter", [">= 0"]
  
end

