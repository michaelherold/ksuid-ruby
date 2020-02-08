# frozen_string_literal: true

module KSUID
  module SchemaStatements
    module NativeDatabaseTypes
      def self.configure
        env_config = ::ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)

        if env_config.count > 0
          env_config.each do |c|
            case c.config["adapter"].to_sym
            when :postgresql
              load_postgresql
            when :sqlite3
              load_sqlite3
            when :mysql
              load_mysql
            end
          end
        else
          load_postgresql
          load_sqlite3
          load_mysql
        end
      end

      def self.load_postgresql
        require "active_record/connection_adapters/postgresql_adapter"
        ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:ksuid] = {
          name: "character varying",
          limit: 27,
        }
      end

      def self.load_sqlite3
        require "active_record/connection_adapters/sqlite3_adapter"
        ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:ksuid] = {
          name: "varchar",
          limit: 27,
        }
      end

      def self.load_mysql
        require "active_record/connection_adapters/abstract_mysql_adapter"
        ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:ksuid] = {
          name: "varchar",
          limit: 27,
        }
      end
    end
  end
end

KSUID::SchemaStatements::NativeDatabaseTypes.configure
