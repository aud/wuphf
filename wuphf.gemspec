# frozen_string_literal: true

require_relative "lib/wuphf/version"

Gem::Specification.new do |spec|
  spec.name = "wuphf"
  spec.version = Wuphf::VERSION
  spec.authors = ["Elliot Dohm"]
  spec.email = ["elliotdohm@gmail.com"]

  spec.summary = "Simple Ruby library that acts as a generic notifier of events"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir['lib/**/*.rb']

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "pry-byebug"
  spec.add_dependency "twilio-ruby", "~> 5.66.0"
  spec.add_development_dependency "mocha", "~> 1.13.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
