# frozen_string_literal: true

module ActiveRecord
  module KSUID
    # Enables the usage of KSUID types within ActiveRecord when Rails is loaded
    #
    # @api private
    class Railtie < ::Rails::Railtie
      initializer 'ksuid' do
        require 'ksuid'

        ActiveSupport.on_load :active_record do
          require 'active_record/ksuid'
        end
      end

      initializer 'ksuid.table_definition' do
        ActiveSupport.on_load :active_record do
          require 'active_record/ksuid/table_definition'

          ActiveRecord::ConnectionAdapters::TableDefinition.include(
            ActiveRecord::KSUID::TableDefinition
          )
        end
      end
    end
  end
end
