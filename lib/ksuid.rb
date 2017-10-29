# frozen_string_literal: true

require_relative 'ksuid/conversions'
require_relative 'ksuid/type'
require_relative 'ksuid/version'

# The K-Sortable Unique IDentifier
module KSUID
  EPOCH_TIME = 1_400_000_000
  PAYLOAD_BYTES = 16
  TIMESTAMP_BYTES = 4
  BYTE_LENGTH = TIMESTAMP_BYTES + PAYLOAD_BYTES
  STRING_LENGTH = 27
  MAX_STRING_ENCODED = 'aWgEPTl1tmebfsQzFP4bxwgy80V'

  extend KSUID::Conversions

  def self.max
    from_bytes([255] * BYTE_LENGTH)
  end

  def self.new(payload: nil, time: Time.now)
    Type.new(payload: payload, time: time)
  end
end
