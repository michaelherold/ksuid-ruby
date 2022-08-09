# frozen_string_literal: true

module ActiveRecord
  module KSUID
    # A string-serialized KSUID for storage within an ActiveRecord database
    #
    # @api private
    #
    # @example Set an attribute as a KSUID using the verbose syntax
    #   class EventWithBareType < ActiveRecord::Base
    #     attribute :ksuid, ActiveRecord::KSUID::Type.new, default: -> { KSUID.new }
    #   end
    #
    # @example Set an attribute as a KSUID using the pre-registered type
    #   class EventWithRegisteredType < ActiveRecord::Base
    #     attribute :ksuid, :ksuid, default: -> { KSUID.new }
    #   end
    class Type < ::ActiveRecord::Type::String
      # Casts a value from user input into a KSUID
      #
      # Type casting happens via the attribute setter and can take input from
      # many places, including:
      #
      #   1. The Rails form builder
      #   2. Directly from the attribute setter
      #   3. From the model initializer
      #
      # @param value [String, Array<Integer>, KSUID::Type] the value to cast into a KSUID
      # @return [KSUID::Type] the type-casted value
      def cast(value)
        ::KSUID.call(value)
      end

      # Converts a value from database input to a KSUID
      #
      # @param value [String, nil] the database-serialized KSUID to convert
      # @return [KSUID::Type] the deserialized KSUID
      def deserialize(value)
        return unless value

        ::KSUID.from_base62(value)
      end

      # Casts the value from a KSUID into a database-understandable format
      #
      # @param value [KSUID::Type, nil] the KSUID in Ruby format
      # @return [String, nil] the base 62-encoded KSUID for storage in the database
      def serialize(value)
        return unless value

        ::KSUID.call(value).to_s
      end
    end
  end
end

ActiveRecord::Type.register(:ksuid, ActiveRecord::KSUID::Type)
