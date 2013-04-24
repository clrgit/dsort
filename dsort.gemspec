# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dsort/version'

Gem::Specification.new do |spec|
  spec.name          = "dsort"
  spec.version       = Dsort::VERSION
  spec.authors       = ["Claus Rasmussen"]
  spec.email         = ["clr@veda.dk"]
  spec.description   = %q{dsort gem}
  spec.summary       = %q{dsort gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
