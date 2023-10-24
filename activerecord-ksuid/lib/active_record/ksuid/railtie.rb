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

          ActiveRecord::ConnectionAdapters::AbstractAdapter.descendants.each do |adapter|
            unless (types = adapter::NATIVE_DATABASE_TYPES)
              Rails.logger <<~MSG.strip_heredoc
                #{adapter.name} was unable to be patched by activerecord-ksuid for
                usage in generators. Please raise an issue with details on which
                adapter this is.
              MSG

              next
            end

            if (string_type = types[:string])
              adapter::NATIVE_DATABASE_TYPES[:ksuid] = { name: string_type[:name] }
            end

            if (binary_type = types[:binary])
              adapter::NATIVE_DATABASE_TYPES[:ksuid_binary] = { name: binary_type[:name] }
            end
          end

          ActiveRecord::ConnectionAdapters::TableDefinition.descendants.each do |defn|
            next unless defn.name

            defn.prepend(ActiveRecord::KSUID::TableDefinition)
          end
        end
      end
    end
  end
end
