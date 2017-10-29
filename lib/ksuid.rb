# frozen_string_literal: true

require_relative 'ksuid/conversions'
require_relative 'ksuid/type'
require_relative 'ksuid/version'

# The K-Sortable Unique IDentifier
module KSUID
  EPOCH_TIME = 1_400_000_000
  BYTES = { payload: 16, timestamp: 4 }.tap do |bytes|
    bytes[:total] = bytes.values.reduce(0, :+)
  end.freeze
  STRING_LENGTH = 27
  MAX_STRING_ENCODED = 'aWgEPTl1tmebfsQzFP4bxwgy80V'

  extend KSUID::Conversions

  def self.max
    from_bytes([255] * BYTES[:total])
  end

  def self.new(payload: nil, time: Time.now)
    Type.new(payload: payload, time: time)
  end
end
