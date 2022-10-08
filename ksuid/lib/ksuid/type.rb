# frozen_string_literal: true

module KSUID
  # Encapsulates the data type for a KSUID
  #
  # This is the main class that you will interact with in this gem. You will
  # not typically generate these directly, but this is the resulting data type
  # for all of the main generation methods on the {KSUID} module.
  #
  # A KSUID type has two pieces of information contained within its
  # byte-encoded data:
  #
  # 1. The timestamp associated with the KSUID (stored as the first 4 bytes)
  # 2. The payload, or random data, for the KSUID (stored as the last 16 bytes)
  #
  # The type gives you access to several handles into these data.
  class Type
    include Comparable

    # Instantiates a new KSUID type
    #
    # @api semipublic
    #
    # @example Generate a new KSUID for the current second
    #   KSUID::Type.new
    #
    # @example Generate a new KSUID for a given timestamp
    #   KSUID::Type.new(time: Time.parse('2017-11-05 15:00:04 UTC'))
    #
    # @param payload [String, Array<Integer>, nil] the payload for the KSUID
    # @param time [Time] the timestamp to use for the KSUID
    # @return [KSUID::Type] the generated KSUID
    def initialize(payload: nil, time: Time.now)
      payload ||= KSUID.config.random_generator.call
      byte_encoding = Utils.int_to_bytes(time.to_i - EPOCH_TIME)

      @uid = byte_encoding.bytes + payload.bytes
    end

    # Implements the Comparable interface for sorting KSUIDs
    #
    # @api private
    #
    # @param other [KSUID::Type] the other object to compare against
    # @return [Integer] -1 for less than other, 0 for equal to, 1 for greater than other
    def <=>(other)
      to_time <=> other.to_time
    end

    # Checks whether this KSUID is equal to another
    #
    # @api semipublic
    #
    # @example Checks whether two KSUIDs are equal
    #   KSUID.new == KSUID.new
    #
    # @param other [KSUID::Type] the other KSUID to check against
    # @return [Boolean]
    def ==(other)
      other.to_s == to_s
    end

    # Checks whether this KSUID hashes to the same hash key as another
    #
    # @api semipublic
    #
    # @example Checks whether two KSUIDs hash to the same key
    #   KSUID.new.eql? KSUID.new
    #
    # @param other [KSUID::Type] the other KSUID to check against
    # @return [Boolean]
    def eql?(other)
      hash == other.hash
    end

    # Generates the key to use when using a KSUID as a hash key
    #
    # @api semipublic
    #
    # @example Using a KSUID as a Hash key
    #   ksuid1 = KSUID.new
    #   ksuid2 = KSUID.from_base62(ksuid1.to_s)
    #   values_by_ksuid = {}
    #
    #   values_by_ksuid[ksuid1] = "example"
    #   values_by_ksuid[ksuid2] #=> "example"
    #
    # @return [Integer]
    def hash
      @uid.hash
    end

    # Prints the KSUID for debugging within a console
    #
    # @api public
    #
    # @example Show the maximum KSUID
    #   KSUID.max.inspect  #=> "<KSUID(aWgEPTl1tmebfsQzFP4bxwgy80V)>"
    #
    # @return [String]
    def inspect
      "<KSUID(#{self})>"
    end

    # The payload for the KSUID, as a hex-encoded string
    #
    # This is generally useful for comparing against the Go tool
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')
    #
    #   ksuid.payload #=> "049CC215C099D42B784DBE99341BD79C"
    #
    # @return [String] a hex-encoded string
    def payload
      Utils.bytes_to_hex_string(uid.last(BYTES[:payload]))
    end

    # The KSUID as a hex-encoded string
    #
    # This is generally useful for comparing against the Go tool.
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')
    #
    #   ksuid.raw #=> "0683F789049CC215C099D42B784DBE99341BD79C"
    #
    # @return [String] a hex-encoded string
    def raw
      Utils.bytes_to_hex_string(uid)
    end

    # The KSUID as a byte string
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')
    #
    #   ksuid.to_bytes
    #
    # @return [String] a byte string
    def to_bytes
      Utils.byte_string_from_array(uid)
    end

    # The KSUID as a Unix timestamp
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')
    #
    #   ksuid.to_i #=> 109311881
    #
    # @return [Integer] the Unix timestamp for the event (without the epoch shift)
    def to_i
      Utils.int_from_bytes(uid.first(BYTES[:timestamp]))
    end

    # The KSUID as a base 62-encoded string
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')
    #
    #   ksuid.to_s #=> "0vdbMgWkU6slGpLVCqEFwkkZvuW"
    #
    # @return [String] the base 62-encoded string for the KSUID
    def to_s
      Base62.encode_bytes(uid)
    end

    # The time the KSUID was generated
    #
    # @api public
    #
    # @example
    #   ksuid = KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')
    #
    #   ksuid.to_time.utc.to_s #=> "2017-10-29 21:18:01 UTC"
    #
    # @return [String] the base 62-encoded string for the KSUID
    def to_time
      Time.at(to_i + EPOCH_TIME)
    end

    private

    # The KSUID as a byte array
    #
    # @api private
    #
    # @return [Array<Integer>]
    attr_reader :uid
  end
end
