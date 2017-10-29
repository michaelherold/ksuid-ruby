# frozen_string_literal: true

RSpec.describe KSUID::Utils do
  it 'can convert between integers and bytes losslessly' do
    number = 123_456_789
    bytes = KSUID::Utils.int_to_bytes(number)
    converted_number = KSUID::Utils.int_from_bytes(bytes)

    expect(converted_number).to eq(number)
  end

  describe '#int_from_bytes' do
    it 'converts a byte string to an integer' do
      number_from_binary = ('1' * 32).to_i(2)
      byte_string = "\xFF" * 4

      converted_number = KSUID::Utils.int_from_bytes(byte_string)

      expect(converted_number).to eq(number_from_binary)
    end

    it 'converts a byte array to an integer' do
      number_from_binary = ('1' * 32).to_i(2)
      byte_array = [255] * 4

      converted_number = KSUID::Utils.int_from_bytes(byte_array)

      expect(converted_number).to eq(number_from_binary)
    end

    it 'handles the maximum ksuid' do
      expected = 1_461_501_637_330_902_918_203_684_832_716_283_019_655_932_542_975

      converted = KSUID::Utils.int_from_bytes([255] * 20)

      expect(converted).to eq(expected)
    end
  end

  describe '#int_to_bytes' do
    it 'converts an integer to a byte string' do
      number_from_binary = ('1' * 32).to_i(2)
      expected = ("\xFF" * 4).bytes

      converted_bytes = KSUID::Utils.int_to_bytes(number_from_binary).bytes

      expect(converted_bytes).to eq(expected)
    end
  end
end
