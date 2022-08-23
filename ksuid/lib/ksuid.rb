# frozen_string_literal: true

require_relative 'ksuid/configuration'
require_relative 'ksuid/version'

# The K-Sortable Unique IDentifier (KSUID)
#
# Distributed systems require unique identifiers to track events throughout
# their subsystems. Many algorithms for generating unique identifiers, like the
# {https://blog.twitter.com/2010/announcing-snowflake Snowflake ID} system,
# require coordination with a central authority. This is an unacceptable
# constraint in the face of systems that run on client devices, yet we still
# need to be able to generate event identifiers and roughly sort them for
# processing.
#
# The KSUID optimizes this problem into a roughly sortable identifier with
# a high possibility space to reduce the chance of collision. KSUID uses
# a 32-bit timestamp with second-level precision combined with 128 bytes of
# random data for the "payload". The timestamp is based on the Unix epoch, but
# with its base shifted forward from 1970-01-01 00:00:00 UTC to 2014-05-13
# 16:532:20 UTC. This is to extend the useful life of the ID format to over
# 100 years.
#
# Because KSUID timestamps use seconds as their unit of precision, they are
# unsuitable to tasks that require extreme levels of precision. If you need
# microsecond-level precision, a format like {https://github.com/alizain/ulid
# ULID} may be more suitable for your use case.
#
# KSUIDs are "roughly sorted". Practically, this means that for any given event
# stream, there may be some events that are ordered in a slightly different way
# than they actually happened. There are two reasons for this. Firstly, the
# format is precise to the second. This means that two events that are
# generated in the same second will be sorted together, but the KSUID with the
# smaller payload value will be sorted first. Secondly, the format is generated
# on the client device using its clock, so KSUID is susceptible to clock shift
# as well. The result of sorting the identifiers is that they will be sorted
# into groups of identifiers that happened in the same second according to
# their generating device.
#
# @example Generate a new KSUID
#   KSUID.new
#
# @example Generate a KSUID prefixed by `evt_`
#   KSUID.prefixed('evt_')
#
# @example Parse a KSUID string that you have received
#   KSUID.from_base62('aWgEPTl1tmebfsQzFP4bxwgy80V')
#
# @example Parse a KSUID byte string that you have received
#   KSUID.from_bytes(
#     "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
#   )
#
# @example Parse a KSUID byte array that you have received
#   KSUID.from_bytes(
#     [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
#      255, 255, 255, 255]
#   )
module KSUID
  # The shift in the Unix epoch time between the standard and the KSUID base
  #
  # @return [Integer] the number of seconds by which we shift the epoch
  EPOCH_TIME = 1_400_000_000

  # The number of bytes that are used to represent each part of a KSUID
  #
  # @return [Hash{Symbol => Integer}] the map of data type to number of bytes
  BYTES = { base62: 27, payload: 16, timestamp: 4, total: 20 }.freeze

  # The number of characters in a base 62-encoded KSUID
  #
  # @return [Integer]
  STRING_LENGTH = 27

  # The maximum KSUID as a base 62-encoded string.
  #
  # @return [String]
  MAX_STRING_ENCODED = 'aWgEPTl1tmebfsQzFP4bxwgy80V'

  autoload :Base62, 'ksuid/base62'
  autoload :Prefixed, 'ksuid/prefixed'
  autoload :Type, 'ksuid/type'
  autoload :Utils, 'ksuid/utils'

  # Converts a KSUID-compatible value into an actual KSUID
  #
  # @api public
  #
  # @example Converts a base 62 KSUID string into a KSUID
  #   KSUID.call('15Ew2nYeRDscBipuJicYjl970D1')
  #
  # @param ksuid [String, Array<Integer>, KSUID::Type] the KSUID-compatible value
  # @return [KSUID::Type] the converted KSUID
  # @raise [ArgumentError] if the value is not KSUID-compatible
  def self.call(ksuid)
    return unless ksuid

    case ksuid
    when KSUID::Prefixed then ksuid.to_ksuid
    when KSUID::Type then ksuid
    when Array then KSUID.from_bytes(ksuid)
    when String then cast_string(ksuid)
    else
      raise ArgumentError, "Cannot convert #{ksuid.inspect} to KSUID"
    end
  end

  # The configuration for creating new KSUIDs
  #
  # @api private
  #
  # @return [KSUID::Configuration] the gem's configuration
  def self.config
    @config ||= KSUID::Configuration.new
  end

  # Configures the KSUID gem by passing a block
  #
  # @api public
  #
  # @example Override the random generator with a null data generator
  #   KSUID.configure do |config|
  #     config.random_generator = -> { "\x00" * KSUID::BYTES[:payload] }
  #   end
  #
  # @example Override the random generator with the faster, but less secure, Random
  #   KSUID.configure do |config|
  #     config.random_generator = -> { Random.new.bytes(KSUID::BYTES[:payload]) }
  #   end
  #
  # @return [KSUID::Configuration] the gem's configuration
  def self.configure
    yield config if block_given?
    config
  end

  # Converts a base 62-encoded string into a KSUID
  #
  # @api public
  #
  # @example Parse a KSUID string into an object
  #   KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')
  #
  # @param string [String] the base 62-encoded KSUID to convert into an object
  # @return [KSUID::Type] the KSUID generated from the string
  def self.from_base62(string)
    string = string.rjust(STRING_LENGTH, Base62::CHARSET[0]) if string.length < STRING_LENGTH
    int = Base62.decode(string)
    bytes = Utils.int_to_bytes(int, 160)

    from_bytes(bytes)
  end

  # Converts a byte string or byte array into a KSUID
  #
  # @api public
  #
  # @example Parse a KSUID byte string into an object
  #   KSUID.from_bytes("\x06\x83\xF7\x89\x04\x9C\xC2\x15\xC0\x99\xD4+xM\xBE\x994\e\xD7\x9C")
  #
  # @param bytes [String, Array<Integer>] the byte string or array to convert into an object
  # @return [KSUID::Type] the KSUID generated from the bytes
  def self.from_bytes(bytes)
    bytes = bytes.bytes if bytes.is_a?(String)

    timestamp = Utils.int_from_bytes(bytes.first(BYTES[:timestamp]))
    payload = Utils.byte_string_from_array(bytes.last(BYTES[:payload]))

    KSUID::Type.new(payload: payload, time: Time.at(timestamp + EPOCH_TIME))
  end

  # Generates the maximum KSUID as a KSUID type
  #
  # @api semipublic
  #
  # @example Generate the maximum KSUID
  #   KSUID.max
  #
  # @return [KSUID::Type] the maximum KSUID in both timestamp and payload
  def self.max
    from_bytes([255] * BYTES[:total])
  end

  # Instantiates a new KSUID
  #
  # @api public
  #
  # @example Generate a new KSUID for the current second
  #   KSUID.new
  #
  # @example Generate a new KSUID for a given timestamp
  #   KSUID.new(time: Time.parse('2017-11-05 15:00:04 UTC'))
  #
  # @param payload [String, Array<Integer>, nil] the payload for the KSUID
  # @param time [Time] the timestamp to use for the KSUID
  # @return [KSUID::Type] the generated KSUID
  def self.new(payload: nil, time: Time.now)
    Type.new(payload: payload, time: time)
  end

  # Instantiates a new {KSUID::Prefixed}
  #
  # @api public
  # @since 0.5.0
  #
  # @example Generate a new prefixed KSUID for the current second
  #   KSUID.prefixed('evt_')
  #
  # @example Generate a new prefixed KSUID for a given timestamp
  #   KSUID.prefixed('cus_', time: Time.parse('2022-08-16 10:36:00 UTC'))
  #
  # @param prefix [String] the prefix to apply to the KSUID
  # @param payload [String, Array<Integer>, nil] the payload for the KSUID
  # @param time [Time] the timestamp to use for the KSUID
  # @return [KSUID::Prefixed] the generated, prefixed KSUID
  def self.prefixed(prefix, payload: nil, time: Time.now)
    Prefixed.new(prefix, payload: payload, time: time)
  end

  # Generates a KSUID string
  #
  # @api public
  # @since 0.5.0
  #
  # @example Generate a new KSUID string for the current second
  #   KSUID.string
  #
  # @example Generate a new KSUID string for a given timestamp
  #   KSUID.string(time: Time.parse('2017-11-05 15:00:04 UTC'))
  #
  # @param payload [String, Array<Integer>, nil] the payload for the KSUID string
  # @param time [Time] the timestamp to use for the KSUID string
  # @return [String] the generated string
  def self.string(payload: nil, time: Time.now)
    Type.new(payload: payload, time: time).to_s
  end

  # Casts a string into a KSUID
  #
  # @api private
  #
  # @param ksuid [String] the string to convert into a KSUID
  # @return [KSUID::Type] the converted KSUID
  def self.cast_string(ksuid)
    if Base62.compatible?(ksuid)
      KSUID.from_base62(ksuid)
    else
      KSUID.from_bytes(ksuid)
    end
  end
  private_class_method :cast_string
end
