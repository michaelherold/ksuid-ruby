# frozen_string_literal: true

module KSUID
  # Contains methods for converting between different types of KSUIDs.
  module Conversions
    def self.extended(base)
      %i[from_bytes from_base62].each do |method_name|
        method = method(method_name)
        base.class.__send__(:define_method, method_name, method.to_proc)
      end
    end

    def self.from_bytes(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      timestamp = Utils.int_from_bytes(bytes.first(BYTES[:timestamp]))
      payload = Utils.byte_string_from_array(bytes.last(BYTES[:payload]))

      KSUID::Type.new(payload: payload, time: Time.at(timestamp + EPOCH_TIME))
    end

    def self.from_base62(string)
      string = string.rjust(STRING_LENGTH, Base62::CHARSET[0]) if string.length < STRING_LENGTH
      int = Base62.decode(string)
      bytes = Utils.int_to_bytes(int)

      from_bytes(bytes)
    end
  end
end
