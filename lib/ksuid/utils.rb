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
        .map { |byte, byte_number| byte << (32 * byte_number) }
        .reduce(0, :+)
    end

    def self.int_to_bytes(int)
      words = int_to_word_array(int)

      Array(words).pack('N*')
    end

    def self.int_to_word_array(int)
      [].tap do |words|
        loop do
          int, remainder = int.divmod(2**32)
          words << remainder

          break unless int.positive?
        end
      end
    end
    private_class_method :int_to_word_array
  end
end
