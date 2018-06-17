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
  gem 'mutant', github: 'mbj/mutant', ref: '3eb55274aa151626eff53df14d1199f2d92b1952'
  gem 'mutant-rspec', github: 'mbj/mutant', ref: '3eb55274aa151626eff53df14d1199f2d92b1952'
  gem 'rubocop', '0.51.0'
  gem 'yard', '~> 0.9'
  gem 'yard-doctest'
  gem 'yardstick'
end

group :development, :test do
  gem 'pry'
  gem 'rake', '< 11'
end

group :ci do
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', require: false
end

group :test do
  gem 'appraisal'
  gem 'rspec', '~> 3.6'
  gem 'timecop'
end
