# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development do
  gem 'benchmark-ips'
  gem 'guard-bundler'
  gem 'guard-inch'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-yard'
  gem 'inch'
  gem 'mutant-rspec'
  gem 'rubocop', '0.92.0'
  gem 'yard', '~> 0.9'
  gem 'yard-doctest'
  gem 'yardstick'

  group :test do
    gem 'appraisal'
    gem 'pry'
    gem 'rake'
    gem 'rspec', '~> 3.6'
    gem 'simplecov', '< 0.18', require: false
  end
end
