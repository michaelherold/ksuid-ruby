# frozen_string_literal: true

require_relative 'utils'

module KSUID
  # Converts between numbers and an alphanumeric encoding
  #
  # We store and report KSUIDs as base 62-encoded numbers to make them
  # lexicographically sortable and compact to transmit. The base 62 alphabet
  # consists of the Arabic numerals, followed by the English capital letters
  # and the English lowercase letters.
  module Base62
    # The character set used to encode numbers into base 62
    #
    # @api private
    CHARSET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

    # The base (62) that this module encodes numbers into
    #
    # @api private
    BASE = CHARSET.size

    # A matcher that checks whether a String has a character outside the charset
    #
    # @api private
    MATCHER = /[^#{CHARSET}]/.freeze

    # Checks whether a string is a base 62-compatible string
    #
    # @api public
    #
    # @example Checks a KSUID for base 62 compatibility
    #   KSUID::Base62.compatible?("15Ew2nYeRDscBipuJicYjl970D1") #=> true
    #
    # @param string [String] the string to check for compatibility
    # @return [Boolean]
    def self.compatible?(string)
      !MATCHER.match?(string)
    end

    # Decodes a base 62-encoded string into an integer
    #
    # @api public
    #
    # @example Decode a string into a number
    #   KSUID::Base62.decode('0000000000000000000001LY7VK')
    #   #=> 1234567890
    #
    # @param ksuid [String] the base 62-encoded number
    # @return [Integer] the decoded number as an integer
    def self.decode(ksuid)
      result = 0

      ksuid.chars.each_with_index do |char, position|
        unless (digit = CHARSET.index(char))
          raise(ArgumentError, "#{ksuid} is not a base 62 number")
        end

        result += digit * (BASE**(ksuid.length - (position + 1)))
      end

      result
    end

    # Encodes a number (integer) as a base 62 string
    #
    # @api public
    #
    # @example Encode a number as a base 62 string
    #   KSUID::Base62.encode(1_234_567_890)
    #   #=> "0000000000000000000001LY7VK"
    #
    # @param number [Integer] the number to encode into base 62
    # @return [String] the base 62-encoded number
    def self.encode(number)
      chars = encode_without_padding(number)

      chars << padding if chars.empty?
      chars.reverse.join.rjust(STRING_LENGTH, padding)
    end

    # Encodes a byte string or byte array into base 62
    #
    # @api semipublic
    #
    # @example Encode a maximal KSUID as a string
    #   KSUID::Base62.encode_bytes(
    #     [255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    #      255, 255, 255, 255, 255, 255, 255, 255, 255, 255]
    #   )
    #
    # @param bytes [String, Array<Integer>] the bytes to encode
    # @return [String] the encoded bytes as a base 62 string
    def self.encode_bytes(bytes)
      encode(Utils.int_from_bytes(bytes))
    end

    # Encodes a number as a string while disregarding the expected width
    #
    # @api private
    #
    # @param number [Integer] the number to encode
    # @return [String] the resulting encoded string
    def self.encode_without_padding(number)
      [].tap do |chars|
        loop do
          break unless number.positive?

          number, remainder = number.divmod(BASE)
          chars << CHARSET[remainder]
        end
      end
    end
    private_class_method :encode_without_padding

    # The character used as padding in strings that are less than 27 characters
    #
    # @api private
    # @return [String]
    def self.padding
      CHARSET[0]
    end
    private_class_method :padding
  end
end
