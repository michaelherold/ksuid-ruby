# frozen_string_literal: true

module KSUID
  # Encapsulates the data type for a prefixed KSUID
  #
  # When you have different types of KSUIDs in your application, it can be
  # helpful to add an identifier to the front of them to give you an idea for
  # what kind of object the KSUID belongs to.
  #
  # For example, you might use KSUIDs to identify both Events and Customers. For
  # an Event, you could prefix the KSUID with the string `evt_`. Likewise, for
  # Customers, you could prefix them with the string `cus_`.
  #
  # {KSUID::Prefixed} gives you affordances for doing just this.
  #
  # ## Ordering
  #
  # {KSUID::Prefixed}s are partially orderable with {KSUID::Type} by their
  # timestamps. When ordering them with other {KSUID::Prefixed} instances, they
  # order first by prefix, then by timestamp. This means that in a mixed
  # collection, all Customer KSUIDs (prefix: `cus_`) would be grouped before all
  # Event KSUIDs (prefix `evt_`).
  #
  # ## Interface
  #
  # You typically will not instantiate this class directly, but instead use the
  # {KSUID.prefixed} builder method to save some typing.
  #
  # The most commonly used helper methods for the {KSUID} module also exist on
  # {KSUID::Prefixed} for converting between different forms of output.
  #
  # ## Differences from {KSUID::Type}
  #
  # One other thing to note is that {KSUID::Prefixed} is not intended to handle
  # binary data because the prefix does not make sense in either the byte string
  # or packed array formats.
  #
  # @since 0.5.0
  class Prefixed < Type
    include Comparable

    # Converts a KSUID-compatible value into a {KSUID::Prefixed}
    #
    # @api public
    #
    # @example Converts a base 62 KSUID string into a {KSUID::Prefixed}
    #   KSUID::Prefixed.call('15Ew2nYeRDscBipuJicYjl970D1', prefix: 'evt_')
    #
    # @param ksuid [String, KSUID::Prefixed, KSUID::Type] the prefixed KSUID-compatible value
    # @return [KSUID::Prefixed] the converted, prefixed KSUID
    # @raise [ArgumentError] if the value is not prefixed KSUID-compatible
    def self.call(ksuid, prefix:)
      return unless ksuid && prefix

      case ksuid
      when KSUID::Prefixed then from_base62(ksuid.to_ksuid.to_s, prefix: prefix)
      when KSUID::Type then from_base62(ksuid.to_s, prefix: prefix)
      when String then cast_string(ksuid, prefix: prefix)
      else
        raise ArgumentError, "Cannot convert #{ksuid.inspect} to KSUID::Prefixed"
      end
    end

    # Converts a base 62-encoded string into a {KSUID::Prefixed}
    #
    # @api public
    #
    # @example Parse a KSUID string into a prefixed object
    #   KSUID::Prefixed.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW', prefix: 'evt_')
    #
    # @param string [String] the base 62-encoded KSUID to convert into an object
    # @param prefix [String] the prefix to add to the KSUID
    # @return [KSUID::Prefixed] the prefixed KSUID generated from the string
    def self.from_base62(string, prefix:)
      string = string.sub(/\A#{prefix}/, '')
      int = Base62.decode(string)
      bytes = Utils.int_to_bytes(int, 160)

      from_bytes(bytes, prefix: prefix)
    end

    # Casts a string into a {KSUID::Prefixed}
    #
    # @api private
    #
    # @param ksuid [String] the string to convert into a {KSUID::Prefixed}
    # @param prefix [String] the prefix to prepend to the KSUID
    # @return [KSUID::Prefixed] the converted, prefixed KSUID
    def self.cast_string(ksuid, prefix:)
      ksuid = ksuid[-KSUID::BYTES[:base62]..-1] if ksuid.length >= KSUID::BYTES[:base62]

      unless Base62.compatible?(ksuid)
        raise ArgumentError, 'Prefixed KSUIDs cannot be binary strings'
      end

      from_base62(ksuid, prefix: prefix)
    end
    private_class_method :cast_string

    # Converts a byte string or byte array into a KSUID
    #
    # @api private
    #
    # @param bytes [String] the byte string to convert into an object
    # @return [KSUID::Prefixed] the prefixed KSUID generated from the bytes
    def self.from_bytes(bytes, prefix:)
      bytes = bytes.bytes
      timestamp = Utils.int_from_bytes(bytes.first(KSUID::BYTES[:timestamp]))
      payload = Utils.byte_string_from_array(bytes.last(KSUID::BYTES[:payload]))

      new(prefix, payload: payload, time: Time.at(timestamp + EPOCH_TIME))
    end
    private_class_method :from_bytes

    # Instantiates a new {KSUID::Prefixed}
    #
    # @api semipublic
    #
    # @example Generate a new {KSUID::Prefixed} for the current second
    #   KSUID::Prefixed.new('evt_')
    #
    # @example Generate a new {KSUID::Prefixed} for a given timestamp
    #   KSUID::Prefixed.new('cus_', time: Time.parse('2017-11-05 15:00:04 UTC'))
    #
    # @param prefix [String] the prefix to add to the KSUID
    # @param payload [String, Array<Integer>, nil] the payload for the KSUID
    # @param time [Time] the timestamp to use for the KSUID
    # @return [KSUID::Prefix] the generated, prefixed KSUID
    def initialize(prefix, payload: nil, time: Time.now)
      raise ArgumentError, 'requires a prefix' unless prefix

      super(payload: payload, time: time)

      @prefix = prefix
    end

    # The prefix in front of the KSUID
    #
    # @api semipublic
    #
    # @example Getting the prefix to create a similar {KSUID::Prefixed}
    #   ksuid1 = KSUID.prefixed('cus_')
    #   ksuid2 = KSUID.prefixed(ksuid1.prefix)
    #
    # @return [String] the prefix of the {KSUID::Prefixed}
    attr_reader :prefix

    # Implements the Comparable interface for sorting {KSUID::Prefixed}s
    #
    # @api private
    #
    # @param other [KSUID::Type] the other object to compare against
    # @return [Integer, nil] nil for uncomparable, -1 for less than other,
    #   0 for equal to, 1 for greater than other
    def <=>(other)
      return unless other.is_a?(Type)
      return super if other.instance_of?(Type)

      if (result = prefix <=> other.prefix).nonzero?
        result
      else
        super
      end
    end

    # Checks whether this {KSUID::Prefixed} is equal to another
    #
    # @api semipublic
    #
    # @example Checks whether two KSUIDs are equal
    #   KSUID.prefixed('evt_') == KSUID.prefixed('evt_')
    #
    # @param other [KSUID::Prefixed] the other {KSUID::Prefixed} to check against
    # @return [Boolean]
    def ==(other)
      other.is_a?(Prefixed) &&
        prefix == other.prefix &&
        super
    end

    # Generates the key to use when using a {KSUID::Prefixed} as a hash key
    #
    # @api semipublic
    #
    # @example Using a KSUID as a Hash key
    #   ksuid1 = KSUID.prefixed('evt_')
    #   ksuid2 = ksuid1.dup
    #   values_by_ksuid = {}
    #
    #   values_by_ksuid[ksuid1] = "example"
    #   values_by_ksuid[ksuid2] #=> "example"
    #
    # @return [Integer]
    def hash
      [prefix, @uid].hash
    end

    # The {KSUID::Prefixed} as a prefixed, hex-encoded string
    #
    # This is generally useful for comparing against the Go tool.
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID::Prefixed.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW', prefix: 'evt_')
    #
    #   ksuid.raw #=> "evt_0683F789049CC215C099D42B784DBE99341BD79C"
    #
    # @return [String] a prefixed, hex-encoded string
    def raw
      super.prepend(prefix)
    end

    # Converts the {KSUID::Prefixed} into a {KSUID::Type} by dropping the prefix
    #
    # @api public
    #
    # @example Convert an Event KSUID into a plain KSUID
    #   ksuid = KSUID.prefixed('evt_')
    #
    #   ksuid.to_ksuid
    #
    # @return [KSUID::Type] the non-prefixed KSUID
    def to_ksuid
      KSUID.from_base62(to_s.sub(/\A#{prefix}/, ''))
    end

    # The {KSUID::Prefixed} as a base 62-encoded string
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID::Prefixed.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW', prefix: 'evt_')
    #
    #   ksuid.to_s #=> "evt_0vdbMgWkU6slGpLVCqEFwkkZvuW"
    #
    # @return [String] the prefixed, base 62-encoded string for the {KSUID::Prefixed}
    def to_s
      super.prepend(prefix)
    end
  end
end
