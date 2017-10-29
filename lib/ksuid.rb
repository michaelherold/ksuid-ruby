# frozen_string_literal: true

require_relative 'ksuid/type'
require 'ksuid/version'

# The K-Sortable Unique IDentifier
module Ksuid
  EPOCH_TIME = 1_400_000_000
  PAYLOAD_BYTES = 16
  TIMESTAMP_BYTES = 4
  BYTE_LENGTH = TIMESTAMP_BYTES + PAYLOAD_BYTES
  STRING_LENGTH = 27
  MAX_STRING_ENCODED = 'aWgEPTl1tmebfsQzFP4bxwgy80V'

  Max = Type.from_bytes([255] * BYTE_LENGTH)

  def self.from_bytes(bytes)
    Type.from_bytes(bytes)
  end

  def self.from_base62(base62)
    Type.from_base62(base62)
  end

  def self.new(payload: nil, time: Time.now)
    Type.new(payload: payload, time: time)
  end
end
