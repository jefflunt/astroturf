# frozen_string_literal: true

require_relative "lib/astroturf/version"

Gem::Specification.new do |spec|
  spec.name          = "astroturf"
  spec.version       = Astroturf::VERSION
  spec.authors       = ["Jeff Lunt"]
  spec.summary       = "Exhaustive synthetic data generator for Rails and Ruby applications"
  spec.description   = "Astroturf generates combinatorial synthetic data graphs in memory from declarative YAML matrix specifications."
  spec.homepage      = "https://github.com/elabs/astroturf"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 12.0"
end
