# frozen_string_literal: true

require 'securerandom'
require_relative 'base62'
require_relative 'utils'

module Ksuid
  # Encapsulates the data type for a ksuid.
  class Type
    include Comparable

    def self.from_bytes(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      timestamp = Utils.int_from_bytes(bytes.first(TIMESTAMP_BYTES))
      payload = Utils.byte_string_from_array(bytes.last(PAYLOAD_BYTES))

      new(payload: payload, time: Time.at(timestamp + EPOCH_TIME))
    end

    def self.from_base62(base62)
      base62 = base62.rjust(STRING_LENGTH, Base62::CHARSET[0]) if base62.length < STRING_LENGTH
      int = Base62.decode(base62)
      bytes = Utils.int_to_bytes(int)

      from_bytes(bytes)
    end

    def initialize(payload: nil, time: Time.now)
      payload ||= SecureRandom.random_bytes(PAYLOAD_BYTES)
      byte_encoding = Utils.int_to_bytes(time.to_i - EPOCH_TIME)

      @uid = byte_encoding.bytes + payload.bytes
    end

    def <=>(other)
      to_time <=> other.to_time
    end

    def ==(other)
      other.to_s == to_s
    end

    def payload
      Utils.byte_string_from_array(uid.last(PAYLOAD_BYTES))
    end

    def to_bytes
      Utils.byte_string_from_array(uid)
    end

    def to_i
      unix_time = Utils.int_from_bytes(uid.first(TIMESTAMP_BYTES))

      unix_time + EPOCH_TIME
    end

    def to_s
      Base62.encode_bytes(to_bytes)
    end

    def to_time
      Time.at(to_i)
    end

    private

    attr_reader :uid
  end
end
