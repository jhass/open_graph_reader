# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "open_graph_reader/version"

Gem::Specification.new do |spec|
  spec.name          = "open_graph_reader"
  spec.version       = OpenGraphReader::VERSION
  spec.authors       = ["Jonne Haß"]
  spec.email         = ["me@jhass.eu"]
  spec.summary       = "OpenGraph protocol parser"
  spec.description   = "A library to fetch and parse OpenGraph properties from an URL or a given string."
  spec.homepage      = "https://github.com/jhass/open_graph_reader"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "spec/**/*", ".yardopts", ".rspec", ".gitmodules", "README.md", "LICENSE.txt"]
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6"
  spec.add_dependency "faraday", ">= 0.9.0"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "webmock", "~> 3.6"
end
