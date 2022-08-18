# frozen_string_literal: true

module ActiveRecord
  module KSUID
    # A string-serialized, prefixed KSUID for storage within an ActiveRecord database
    #
    # @api private
    # @since 0.5.0
    #
    # @example Set an attribute as a prefixed KSUID using the verbose syntax
    #   class EventWithBarePrefixedType < ActiveRecord::Base
    #     attribute(
    #       :ksuid,
    #       ActiveRecord::KSUID::PrefixedType.new(prefix: 'evt_'),
    #       default: -> { KSUID.prefixed('evt_') }
    #     )
    #   end
    #
    # @example Set an attribute as a prefixed KSUID using the pre-registered type
    #   class EventWithRegisteredPrefixedType < ActiveRecord::Base
    #     attribute :ksuid, :ksuid_prefixed, prefix: 'evt_', default: -> { KSUID.prefixed('evt_') }
    #   end
    class PrefixedType < ::ActiveRecord::Type::String
      # Instantiates an ActiveRecord::Type for handling prefixed KSUIDs
      #
      # @param prefix [String] the prefix to add to the KSUID
      def initialize(prefix: '')
        @prefix = prefix
        super()
      end

      # Casts a value from user input into a {KSUID::Prefixed}
      #
      # Type casting happens via the attribute setter and can take input from
      # many places, including:
      #
      #   1. The Rails form builder
      #   2. Directly from the attribute setter
      #   3. From the model initializer
      #
      # @param value [String, Array<Integer>, KSUID::Prefixed] the value to cast into a KSUID
      # @return [KSUID::Prefixed] the type-casted value
      def cast(value)
        ::KSUID::Prefixed.call(value, prefix: @prefix)
      end

      # Converts a value from database input to a {KSUID::Prefixed}
      #
      # @param value [String, nil] the database-serialized, prefixed KSUID to convert
      # @return [KSUID::Prefixed] the deserialized, prefixed KSUID
      def deserialize(value)
        return unless value

        ::KSUID::Prefixed.from_base62(value, prefix: @prefix)
      end

      # Casts the value from a KSUID into a database-understandable format
      #
      # @param value [KSUID::Prefixed, nil] the prefixed KSUID in Ruby format
      # @return [String, nil] the base 62-encoded, prefixed KSUID for storage in the database
      def serialize(value)
        return unless value

        ::KSUID::Prefixed.call(value, prefix: @prefix).to_s
      end
    end
  end
end

ActiveRecord::Type.register(:ksuid_prefixed, ActiveRecord::KSUID::PrefixedType)
