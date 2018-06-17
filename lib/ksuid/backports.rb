# frozen_string_literal: true

module KSUID
  # Contains backports for recently added Ruby functionality
  #
  # @api private
  module Backports
    refine String do
      unless ''.respond_to?(:unpack1)
        # Decodes the string (which may contain binary data) according to the format string
        #
        # @api public
        #
        # @see https://ruby-doc.org/core-2.5.1/String.html#method-i-unpack1
        # @see https://ruby-doc.org/core-2.5.1/String.html#method-i-unpack
        #
        # @param format [String] the format string for what to unpack
        # @return [String] the first value extracted
        def unpack1(format)
          unpack(format).first
        end
      end
    end
  end
end
