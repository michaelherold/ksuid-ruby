# frozen_string_literal: true

require File.expand_path(File.join(__dir__, 'lib', 'active_record', 'ksuid', 'version'))

Gem::Specification.new do |spec|
  spec.name    = 'activerecord-ksuid'
  spec.version = ActiveRecord::KSUID::VERSION
  spec.authors = ['Michael Herold']
  spec.email   = ['opensource@michaeljherold.com']

  spec.summary     = 'ActiveRecord integration for KSUIDs using the ksuid gem'
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/michaelherold/ksuid-ruby'
  spec.license     = 'MIT'

  spec.files = %w[CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md UPGRADING.md]
  spec.files += %w[activerecord-ksuid.gemspec]
  spec.files += Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'activerecord', '>= 6.0'
  spec.add_dependency 'ksuid', '~> 1.0'

  spec.add_development_dependency 'bundler', '>= 1.15'
end
