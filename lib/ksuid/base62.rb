# frozen_string_literal: true

require_relative 'utils'

module KSUID
  # Converts between numbers and an alphanumeric encoding.
  module Base62
    CHARSET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    BASE = CHARSET.size

    def self.decode(ksuid)
      result = 0

      ksuid.split('').each_with_index do |char, position|
        unless (digit = CHARSET.index(char))
          raise(ArgumentError, "#{ksuid} is not a base 62 number")
        end

        result += digit * BASE**(ksuid.length - (position + 1))
      end

      result
    end

    def self.encode(number)
      chars = _encode(number)

      chars << padding if chars.empty?
      chars.reverse.join('').rjust(STRING_LENGTH, padding)
    end

    def self.encode_bytes(bytes)
      encode(Utils.int_from_bytes(bytes))
    end

    def self._encode(number)
      [].tap do |chars|
        loop do
          break unless number.positive?

          number, remainder = number.divmod(BASE)
          chars << CHARSET[remainder]
        end
      end
    end
    private_class_method :_encode

    def self.padding
      CHARSET[0]
    end
    private_class_method :padding
  end
end
