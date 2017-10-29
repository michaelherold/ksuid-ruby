# frozen_string_literal: true

module KSUID
  # Contains methods for converting between different types of KSUIDs.
  module Conversions
    def from_bytes(bytes)
      bytes = bytes.bytes if bytes.is_a?(String)

      timestamp = Utils.int_from_bytes(bytes.first(TIMESTAMP_BYTES))
      payload = Utils.byte_string_from_array(bytes.last(PAYLOAD_BYTES))

      KSUID::Type.new(payload: payload, time: Time.at(timestamp + EPOCH_TIME))
    end

    def from_base62(base62)
      base62 = base62.rjust(STRING_LENGTH, Base62::CHARSET[0]) if base62.length < STRING_LENGTH
      int = Base62.decode(base62)
      bytes = Utils.int_to_bytes(int)

      from_bytes(bytes)
    end
  end
end
