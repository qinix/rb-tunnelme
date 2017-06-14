# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tunnelme/version"

Gem::Specification.new do |spec|
  spec.name          = "tunnelme"
  spec.version       = Tunnelme::VERSION
  spec.authors       = ["Eric Zhang"]
  spec.email         = ["i@qinix.com"]

  spec.summary       = %q{localtunnel.me client for Ruby}
  spec.description   = %q{localtunnel.me client for Ruby}
  spec.homepage      = "https://github.com/qinix/rb-tunnelme"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty'
  spec.add_dependency 'eventmachine'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
