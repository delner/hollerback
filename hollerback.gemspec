# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hollerback/version'

Gem::Specification.new do |spec|
  spec.name          = "hollerback"
  spec.version       = Hollerback::VERSION
  spec.authors       = ["David Elner"]
  spec.email         = ["david@davidelner.com"]

  spec.summary       = %q{Callback pattern for Ruby classes.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-hollerback-mocks", "~> 0.1"
  spec.add_development_dependency "pry"
end
