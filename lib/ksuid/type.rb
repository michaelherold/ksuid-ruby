# frozen_string_literal: true

require 'securerandom'
require_relative 'base62'
require_relative 'utils'

module KSUID
  # Encapsulates the data type for a ksuid.
  class Type
    include Comparable

    def initialize(payload: nil, time: Time.now)
      payload ||= SecureRandom.random_bytes(BYTES[:payload])
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
      Utils.byte_string_from_array(uid.last(BYTES[:payload]))
    end

    def to_bytes
      Utils.byte_string_from_array(uid)
    end

    def to_i
      unix_time = Utils.int_from_bytes(uid.first(BYTES[:timestamp]))

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
