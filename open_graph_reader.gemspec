# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'open_graph_reader/version'

Gem::Specification.new do |spec|
  spec.name          = "open_graph_reader"
  spec.version       = OpenGraphReader::VERSION
  spec.authors       = ["Jonne Haß"]
  spec.email         = ["me@jhass.eu"]
  spec.summary       = %q{OpenGraph protocol parser}
  spec.description   = %q{A library to fetch and parse OpenGraph properties from an URL or a given string.}
  spec.homepage      = "https://github.com/jhass/opengraph_reader"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "spec/**/*", ".yardopts", ".rspec", ".gitmodules"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6"
  spec.add_dependency "faraday", "~> 0.9.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "webmock", "~> 1.20"
end
