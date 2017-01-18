# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loggie/version'

Gem::Specification.new do |spec|
  spec.name          = "loggie"
  spec.version       = Loggie::VERSION
  spec.authors       = ["Ian Vaughan"]
  spec.email         = ["github@ianvaughan.co.uk"]

  spec.summary       = %q{Enables search of log files}
  spec.description   = %q{Searches remote log files via API}
  spec.homepage      = "https://github.com/IanVaughan/loggie"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   << "loggie"
  spec.require_paths = ["lib"]

  spec.add_dependency "dotenv", "~> 2.1"
  spec.add_dependency "activesupport", "~> 5.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "timecop", "~> 0.7"
  spec.add_development_dependency "vcr", "~> 2.9"
  spec.add_development_dependency "webmock", "~> 1.22"
end
