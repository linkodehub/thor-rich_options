# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thor/rich_options/version'

Gem::Specification.new do |spec|
  spec.name          = "thor-rich_options"
  spec.version       = Thor::RichOptions::VERSION
  spec.authors       = ["satoyama"]
  spec.email         = ["satoyama@linkode.co.jp"]

  spec.summary       = %q{Rich Options for Thor}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/linkodehub/thor-rich_options"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "pry"
  #spec.add_development_dependency "pry-debugger"
  #spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.0"
  spec.add_development_dependency "simplecov", ">= 0.9"
  spec.add_development_dependency "childlabor"
  spec.add_development_dependency "coveralls", '>= 0.5.7'
  spec.add_development_dependency "webmock", ">= 1.20"
  spec.add_development_dependency "rubocop", ">=  0.19"
  spec.add_development_dependency "fakeweb"


  spec.add_runtime_dependency "thor", "0.19.1"
end
