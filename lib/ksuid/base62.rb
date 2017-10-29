# frozen_string_literal: true

require_relative 'utils'

module Ksuid
  # Converts between numbers and an alphanumeric encoding.
  module Base62
    CHARSET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    BASE = CHARSET.size

    def self.decode(base62)
      length = base62.length
      result = 0

      base62.split('').each_with_index do |x, i|
        raise(ArgumentError, "#{base62} is not a base 62 number") unless (digit = CHARSET.index(x))

        result += digit * BASE**(length - (i + 1))
      end

      result
    end

    def self.encode(number)
      chars = []

      loop do
        break unless number.positive?

        number, remainder = number.divmod(BASE)

        chars << CHARSET[remainder]
      end

      chars << CHARSET[0] if chars.empty?
      chars.reverse.join('').rjust(STRING_LENGTH, CHARSET[0])
    end

    def self.encode_bytes(bytes)
      encode(Utils.int_from_bytes(bytes))
    end
  end
end
