# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/jira_versions/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-jira_versions'
  spec.version       = Fastlane::JiraVersions::VERSION
  spec.author        = %q{Sandy Chapman}
  spec.email         = %q{sandychapman@gmail.com}

  spec.summary       = %q{Manage your JIRA project's releases/versions with this plugin.}
  spec.homepage      = "https://github.com/SandyChapman/fastlane-plugin-jira_versions"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'jira-ruby', '~> 1.1.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.102.0'
end
