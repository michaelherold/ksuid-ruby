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
  gem 'mutant-rspec'
  gem 'yard', '~> 0.9'
  gem 'yardstick'

  group :test do
    gem 'appraisal'
    gem 'pry'
    gem 'rake'
    gem 'rspec', '~> 3.6'
    gem 'simplecov', '< 0.18', require: false

    group :linting do
      gem 'yard-doctest'
    end
  end

  group :linting do
    gem 'inch'
    gem 'rubocop', '0.92.0'
  end
end
