# frozen_string_literal: true

require 'sequel'
require 'sqlite3' unless RUBY_ENGINE == 'jruby'
require 'ksuid'
