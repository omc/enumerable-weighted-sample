# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enumerable_weighted_sample/version'

Gem::Specification.new do |spec|
  spec.name          = "enumerable_weighted_sample"
  spec.version       = EnumerableWeightedSample::VERSION
  spec.authors       = ["Christine Oen"]
  spec.email         = ["oen.christine@gmail.com"]

  spec.summary       = %q{Produce a weighted random sampling based on the weights calculated from a given block.}
  spec.homepage      = "https://github.com/omc/enumerable-weighted-sample"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
