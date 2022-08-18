# frozen_string_literal: true

require 'bundler/gem_tasks'

# Defines a Rake task if the optional dependency is installed
#
# @return [nil]
def with_optional_dependency
  yield if block_given?
rescue LoadError # rubocop:disable Lint/SuppressedException
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

default = %w[spec]

with_optional_dependency do
  require 'yard-doctest'
  desc 'Run tests on the examples in documentation strings'
  task 'yard:doctest' do
    command = String.new('yard doctest')
    env = {}
    if (gemfile = ENV.fetch('BUNDLE_GEMFILE', nil))
      env['BUNDLE_GEMFILE'] = gemfile
    elsif !ENV['APPRAISAL_INITIALIZED']
      command.prepend('appraisal rails-6.0 ')
    end
    success = system(env, command)

    abort "\nYard Doctest failed: #{$CHILD_STATUS}" unless success
  end

  default << 'yard:doctest'
end

with_optional_dependency do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)

  default << 'rubocop'
end

with_optional_dependency do
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new(:yard)

  default << 'yard'
end

with_optional_dependency do
  require 'inch/rake'
  Inch::Rake::Suggest.new(:inch)

  default << 'inch'
end

with_optional_dependency do
  require 'yardstick/rake/measurement'
  options = YAML.load_file('.yardstick.yml')
  Yardstick::Rake::Measurement.new(:yardstick_measure, options) do |measurement|
    measurement.output = 'coverage/docs.txt'
  end

  require 'yardstick/rake/verify'
  options = YAML.load_file('.yardstick.yml')
  Yardstick::Rake::Verify.new(:yardstick_verify, options) do |verify|
    verify.threshold = 100
  end

  task yardstick: %i[yardstick_measure yardstick_verify]
end

if ENV['CI']
  # no-op
elsif !ENV['APPRAISAL_INITIALIZED']
  require 'appraisal/task'
  Appraisal::Task.new
  default -= %w[spec yard:doctest] + %w[appraisal]
else
  ENV['COVERAGE'] = '1'
  default &= %w[spec yard:doctest]
end

task default: default
