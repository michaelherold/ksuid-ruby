# frozen_string_literal: true

module KSUID
  # A set of helper functions.
  module Utils
    def self.byte_string_from_array(bytes)
      bytes.pack('C*')
    end

    def self.bytes_to_hex_string(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      byte_string_from_array(bytes)
        .unpack('H*')
        .first
        .upcase
    end

    def self.int_from_bytes(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      byte_string_from_array(bytes)
        .unpack('N*')
        .each_with_index
        .map { |byte, byte_number| byte << (32 * byte_number) }
        .reduce(0, :+)
    end

    def self.int_to_bytes(int, bits = 32)
      int
        .to_s(2)
        .rjust(bits, '0')
        .split('')
        .each_slice(8)
        .map { |digits| digits.join.to_i(2) }
        .pack("C#{bits / 8}")
    end
  end
end
