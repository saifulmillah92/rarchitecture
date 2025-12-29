# frozen_string_literal: true

require_relative "lib/rarchitecture/version"

Gem::Specification.new do |spec|
  spec.name = "rarchitecture"
  spec.version = RArchitecture::VERSION
  spec.authors = ["saifulmillah92"]
  spec.email = ["saifulmillah92@gmail.com"]

  spec.summary       = "Opinionated Rails architecture patterns for clarity and maintainability"
  spec.description   = "RArchitecture provides reusable conventions, helpers, and structure guidelines to help Rails developers build audit-friendly, scalable applications. It emphasizes clear boundaries between controllers, services, and outputs, with a focus on maintainable code and onboarding clarity."
  spec.homepage      = "https://github.com/saifulm/rarchitecture"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = "https://github.com/saifulm/rarchitecture"
  spec.metadata["source_code_uri"] = "https://github.com/saifulm/rarchitecture"
  spec.metadata["changelog_uri"] = "https://github.com/saifulm/rarchitecture"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "rubocop-rspec"
end
