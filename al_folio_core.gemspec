# frozen_string_literal: true

require_relative "lib/al_folio_core/version"

Gem::Specification.new do |spec|
  spec.name = "al_folio_core"
  spec.version = AlFolioCore::VERSION
  spec.authors = ["al-folio maintainers"]
  spec.email = ["maintainers@al-folio.dev"]

  spec.summary = "Core runtime plugin for al-folio v1.x"
  spec.description = "Provides al-folio core runtime hooks, version contract checks, and migration warnings."
  spec.homepage = "https://github.com/al-org-dev/al-folio-core"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
  }

  spec.files = Dir[
    "lib/**/*",
    "migrations/**/*",
    "scripts/**/*",
    "_scripts/**/*",
    "_includes/**/*",
    "_layouts/**/*",
    "_sass/**/*",
    "assets/**/*",
    "LICENSE",
    "README.md",
    "CHANGELOG.md",
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 3.9", "< 5.0"
  spec.add_dependency "liquid", ">= 4.0", "< 6.0"

  spec.add_development_dependency "bundler", ">= 2.0", "< 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
