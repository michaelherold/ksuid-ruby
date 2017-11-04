# frozen_string_literal: true

require_relative 'ksuid/type'
require_relative 'ksuid/version'

# The K-Sortable Unique IDentifier
module KSUID
  EPOCH_TIME = 1_400_000_000
  BYTES = { payload: 16, timestamp: 4, total: 20 }.freeze
  STRING_LENGTH = 27
  MAX_STRING_ENCODED = 'aWgEPTl1tmebfsQzFP4bxwgy80V'

  def self.from_base62(string)
    string = string.rjust(STRING_LENGTH, Base62::CHARSET[0]) if string.length < STRING_LENGTH
    int = Base62.decode(string)
    bytes = Utils.int_to_bytes(int, 160)

    from_bytes(bytes)
  end

  def self.from_bytes(bytes)
    bytes = bytes.bytes if bytes.is_a?(String)

    timestamp = Utils.int_from_bytes(bytes.first(BYTES[:timestamp]))
    payload = Utils.byte_string_from_array(bytes.last(BYTES[:payload]))

    KSUID::Type.new(payload: payload, time: Time.at(timestamp + EPOCH_TIME))
  end

  def self.max
    from_bytes([255] * BYTES[:total])
  end

  def self.new(payload: nil, time: Time.now)
    Type.new(payload: payload, time: time)
  end
end
