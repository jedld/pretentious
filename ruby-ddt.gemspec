# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ddt/version'

Gem::Specification.new do |spec|
  spec.name          = "ddt"
  spec.version       = Ddt::VERSION
  spec.authors       = ["Joseph Emmanuel Dayo"]
  spec.email         = ["joseph.dayo@gmail.com"]
  spec.summary       = %q{gem to deal with pretentious tdd developers}
  spec.description   = %q{Do you have a pretentious boss or dev lead that pushes you to embrace tdd but for reasons hate it or them? here is a gem to deal with that.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency "binding_of_caller", "~> 0.7.2"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
