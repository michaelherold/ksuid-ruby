# frozen_string_literal: true

module KSUID
  # Utility functions for converting between different encodings
  #
  # @api private
  module Utils
    # Converts a byte string into a byte array
    #
    # @param bytes [String] a byte string
    # @return [Array<Integer>] an array of bytes from the byte string
    def self.byte_string_from_array(bytes)
      bytes.pack('C*')
    end

    # Converts a byte string or byte array into a hex-encoded string
    #
    # @param bytes [String|Array<Integer>] the byte string or array
    # @return [String] the byte string as a hex-encoded string
    def self.bytes_to_hex_string(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      byte_string_from_array(bytes)
        .unpack('H*')
        .first
        .upcase
    end

    # Converts a byte string or byte array into an integer
    #
    # @param bytes [String|Array<Integer>] the byte string or array
    # @return [Integer] the resulting integer
    def self.int_from_bytes(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      bytes
        .map { |byte| byte.to_s(2).rjust(8, '0') }
        .join('')
        .to_i(2)
    end

    # Converts an integer into a network-ordered (big endian) byte string
    #
    # @param int [Integer] the integer to convert
    # @param bits [Integer] the expected number of bits for the result
    # @return [String] the byte string
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
