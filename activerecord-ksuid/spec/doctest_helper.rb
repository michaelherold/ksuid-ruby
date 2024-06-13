# frozen_string_literal: true

require 'rails'
require 'active_record'
require 'logger'

require 'active_record/ksuid/railtie'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false

ActiveRecord::KSUID::Railtie.initializers.each(&:run)
ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

ActiveSupport::Deprecation.instance.silenced = true
