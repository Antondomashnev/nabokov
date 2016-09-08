# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nabokov/version"

Gem::Specification.new do |spec|
  spec.name          = "nabokov"
  spec.version       = Nabokov::VERSION
  spec.authors       = ["Anton Domashnev"]
  spec.email         = ["antondomashnev@gmail.com"]
  spec.description   = Nabokov::DESCRIPTION
  spec.summary       = "Move mobile localization boringness away from you 🏃"
  spec.homepage      = "https://github.com/Antondomashnev/nabokov"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_runtime_dependency "rspec", "~> 3.4"
  spec.add_runtime_dependency "git", "~> 1.0"
  spec.add_runtime_dependency "claide", "~> 1.0"
  spec.add_runtime_dependency "cork", "~> 0.1"

  spec.add_development_dependency "rubocop", "~> 0.42"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
