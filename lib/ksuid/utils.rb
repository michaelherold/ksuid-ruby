# frozen_string_literal: true

module KSUID
  # A set of helper functions.
  module Utils
    def self.byte_string_from_array(bytes)
      bytes.pack('C*')
    end

    def self.int_from_bytes(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      byte_string_from_array(bytes)
        .unpack('N*')
        .each_with_index
        .map { |n, i| n << (32 * i) }
        .reduce(0, :+)
    end

    def self.int_to_bytes(n)
      words = []

      loop do
        n, remainder = n.divmod(2**32)
        words << remainder

        break unless n.positive?
      end

      Array(words).pack('N*')
    end
  end
end
