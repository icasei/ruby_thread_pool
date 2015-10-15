# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "ruby_thread_pool/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby_thread_pool"
  spec.version       = RubyThreadPool::VERSION
  spec.authors       = ["Hugo Luchessi Neto"]
  spec.email         = ["hugoluchessi@gmail.com"]

  spec.summary       = %q{Simple ruby thread pool implementation}
  spec.description   = %q{Simple ruby thread pool implementation}
  spec.homepage      = "https://github.com/hugo1987br/ruby_thread_pool"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
