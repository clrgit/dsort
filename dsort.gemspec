# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dsort/version'

Gem::Specification.new do |spec|
  spec.name          = "dsort"
  spec.version       = Dsort::VERSION
  spec.authors       = ["Claus Rasmussen"]
  spec.email         = ["claus.l.rasmussen@gmail.com"]
  spec.description   = %q{dsort - an easier to use version of TSort}
  spec.summary       = %q{
                          dsort is an easier-to-use alternative to the standard
                          library TSort module: Data can be specified as simple
                          array or by a block and tsort is defined as
                          topological sort in mathematics (see
                          http://en.wikipedia.org/wiki/Topological_sorting).
                          The behavior of TSort::tsort is provided by the dsort
                          method but with the same interface as DSort::tsort
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
