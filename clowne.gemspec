# frozen_string_literal: true

require_relative "lib/clowne/version"

Gem::Specification.new do |spec|
  spec.name = "clowne"
  spec.version = Clowne::VERSION
  spec.authors = ["Vladimir Dementyev", "Sverchkov Nikolay"]
  spec.email = ["palkan@evilmartians.com", "ssnikolay@gmail.com"]

  spec.summary = "A flexible gem for cloning your models"
  spec.description = "A flexible gem for cloning your models."
  spec.homepage = "https://github.com/clowne-rb/clowne"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]

  spec.metadata = {
    "bug_tracker_uri" => "http://github.com/clowne-rb/clowne/issues",
    "changelog_uri" => "https://github.com/clowne-rb/clowne/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://clowne.evilmartians.io/",
    "homepage_uri" => "https://clowne.evilmartians.io/",
    "source_code_uri" => "http://github.com/clowne-rb/clowne"
  }

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "factory_bot", ">= 5"
end
