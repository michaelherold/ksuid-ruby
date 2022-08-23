# frozen_string_literal: true

module ActiveRecord
  module KSUID
    # Extends ActiveRecord's table definition language for KSUIDs
    module TableDefinition
      # Defines a field as a string-based KSUID
      #
      # @example Define a KSUID field as a non-primary key
      #   ActiveRecord::Schema.define do
      #     create_table :events, force: true do |table|
      #       table.ksuid :ksuid, index: true, unique: true
      #     end
      #   end
      #
      # @example Define a KSUID field as a primary key
      #   ActiveRecord::Schema.define do
      #     create_table :events, force: true, id: false do |table|
      #       table.ksuid :id, primary_key: true
      #     end
      #   end
      #
      # @param args [Array<Symbol>] the list of fields to define as KSUIDs
      # @param options [Hash] see {ActiveRecord::ConnectionAdapters::TableDefinition}
      # @option options [String] :prefix the prefix expected in front of the KSUID
      # @return [void]
      def ksuid(*args, **options)
        prefix_length = options.delete(:prefix)&.length || 0

        args.each { |name| column(name, :string, **options.merge(limit: 27 + prefix_length)) }
      end

      # Defines a field as a binary-based KSUID
      #
      # @example Define a KSUID field as a non-primary key
      #   ActiveRecord::Schema.define do
      #     create_table :events, force: true do |table|
      #       table.ksuid_binary :ksuid, index: true, unique: true
      #     end
      #   end
      #
      # @example Define a KSUID field as a primary key
      #   ActiveRecord::Schema.define do
      #     create_table :events, force: true, id: false do |table|
      #       table.ksuid_binary :id, primary_key: true
      #     end
      #   end
      #
      # @param args [Array<Symbol>] the list of fields to define as KSUIDs
      # @param options [Hash] see {ActiveRecord::ConnectionAdapters::TableDefinition}
      # @return [void]
      def ksuid_binary(*args, **options)
        args.each { |name| column(name, :binary, **options.merge(limit: 20)) }
      end
    end
  end
end
