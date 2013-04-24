# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dsort/version'

Gem::Specification.new do |spec|
  spec.name          = "dsort"
  spec.version       = Dsort::VERSION
  spec.authors       = ["Claus Rasmussen"]
  spec.email         = ["clr@veda.dk"]
  spec.description   = %q{dsort - an easier to use version of TSort}
  spec.summary       = %q{
                          dsort is an easier to use version of the standard
                          library TSort module. It implement the dsort method
                          for dependency sorts and tsort for topological sorts.
                          Compared to TSort the DSort::tsort method reverses
                          its output, while DSort::dsort result in the same
                          sorting order as TSort::tsort. This is done to make
                          DSort::tsort behave as defined in general
                          mathematics. See
                          http://en.wikipedia.org/wiki/Topological_sorting
                      }
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
