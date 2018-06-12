# frozen_string_literal: true

require 'rails'
require 'active_record'
require 'ksuid'
require 'ksuid/activerecord'

YARD::Doctest.configure do |doctest|
  doctest.skip 'KSUID::ActiveRecord::TableDefinition'
end
