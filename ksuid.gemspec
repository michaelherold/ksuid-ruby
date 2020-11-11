# frozen_string_literal: true

require File.expand_path(File.join('..', 'lib', 'ksuid', 'version'), __FILE__)

Gem::Specification.new do |spec|
  spec.name    = 'ksuid'
  spec.version = KSUID::VERSION
  spec.authors = ['Michael Herold']
  spec.email   = ['michael@michaeljherold.com']

  spec.summary     = 'Ruby implementation of the K-Sortable Unique IDentifier'
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/michaelherold/ksuid'
  spec.license     = 'MIT'

  spec.files = %w[CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md]
  spec.files += %w[ksuid.gemspec]
  spec.files += Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.15'
end
