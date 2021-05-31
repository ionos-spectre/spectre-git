require_relative 'lib/spectre/git'

Gem::Specification.new do |spec|
  spec.name          = "spectre-git"
  spec.version       = Spectre::Git::VERSION
  spec.authors       = ["Christian Neubauer"]
  spec.email         = ["me@christianneubauer.de"]

  spec.summary       = "Git module for spectre"
  spec.description   = "Adds git command to the spectre framework"
  spec.homepage      = "https://bitbucket.org/cneubaur/spectre-git"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://bitbucket.org/cneubaur/spectre-git"
  spec.metadata["changelog_uri"] = "https://bitbucket.org/cneubaur/spectre-git/src/master/CHANGELOG.md"

  spec.files        += Dir.glob('lib/**/*')

  spec.bindir        = "exe"
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'git', '>= 1.8.0'
  spec.add_runtime_dependency 'spectre-core', '>= 1.8.0'
end
