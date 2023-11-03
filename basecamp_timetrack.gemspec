# frozen_string_literal: true

require_relative "lib/basecamp_timetrack/version"

Gem::Specification.new do |spec|
  spec.name = "basecamp_timetrack"
  spec.version = BasecampTimetrack::VERSION
  spec.authors = ["k0va1"]
  spec.email = ["al3xander.koval@gmail.com"]

  spec.summary = "Groups and sums working hours by tasks"
  spec.description = "Groups and sums working hours by tasks"
  spec.homepage = "https://github.com/k0va1/basecamp_timetrack"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/k0va1/basecamp_timetrack"
  spec.metadata["changelog_uri"] = "https://github.com/k0va1/basecamp_timetrack/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "oauth2"
  spec.add_dependency "launchy"
  spec.add_dependency "faraday"
  spec.add_dependency "tty-table"
  spec.add_dependency "invoice_printer"
  spec.add_dependency "invoice_printer_fonts"


  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
