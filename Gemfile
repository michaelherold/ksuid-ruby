# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development do
  gem 'guard-bundler'
  gem 'guard-inch'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-yard'
  gem 'mutant-rspec'
  gem 'rubocop', '0.51.0'
end

group :development, :test do
  gem 'pry'
  gem 'rake', '< 11'
end

group :ci do
  gem 'codeclimate-test-reporter', require: false
  gem 'inch', require: false
  gem 'simplecov', require: false
  gem 'yard', '~> 0.8', require: false
  gem 'yardstick', require: false
end

group :test do
  gem 'rspec', '~> 3.6'
end
