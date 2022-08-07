# frozen_string_literal: true

require 'rails'
require 'active_record'
require 'ksuid'
require 'ksuid/activerecord'
require 'ksuid/activerecord/table_definition'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false
