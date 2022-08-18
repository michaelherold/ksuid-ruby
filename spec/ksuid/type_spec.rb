# frozen_string_literal: true

RSpec.describe KSUID::Type do
  describe 'value object semantics' do
    it 'uses value comparison instead of identity comparison' do
      ksuid1 = KSUID.new(time: Time.now)
      ksuid2 = KSUID.from_base62(ksuid1.to_s)
      hash = {}

      hash[ksuid1] = 'Hello, world'

      aggregate_failures do
        expect(ksuid1).to eq ksuid2
        expect(ksuid1).to eql ksuid2
        expect(ksuid1).not_to equal ksuid2
        expect(hash[ksuid2]).to eq 'Hello, world'
      end
    end
  end

  describe '.from_base62' do
    it 'converts a base62 KSUID properly' do
      ksuid = KSUID.from_base62(KSUID::MAX_STRING_ENCODED)

      expect(ksuid).to eq(KSUID.max)
    end
  end

  describe '#<=>' do
    it 'sorts the KSUIDs by timestamp' do
      ksuid1 = KSUID.new(time: Time.now)
      ksuid2 = KSUID.new(time: Time.now + 1)

      array = [ksuid2, ksuid1].sort

      expect(array).to eq([ksuid1, ksuid2])
    end
  end

  describe '#==' do
    it 'matches against other KSUID::Types as well as String' do
      ksuid1 = KSUID.new(time: Time.now)
      ksuid2 = KSUID.from_base62(ksuid1.to_s)

      aggregate_failures do
        expect(ksuid1).to eq ksuid2
        expect(ksuid1).to eq ksuid2.to_s
      end
    end
  end

  describe '#inspect' do
    it 'shows the string representation for easy understanding' do
      ksuid = KSUID.max

      expect(ksuid.inspect).to match('aWgEPTl1tmebfsQzFP4bxwgy80V')
    end
  end

  describe '#payload' do
    it 'returns the payload as a byte string' do
      expected = 'F' * 32

      array = KSUID.max.payload

      expect(array).to eq(expected)
    end
  end

  describe '#to_bytes' do
    it 'returns the ksuid as a byte string' do
      expected = ("\xFF" * 20).bytes

      array = KSUID.max.to_bytes.bytes

      expect(array).to eq(expected)
    end
  end

  describe '#to_time' do
    it 'returns the times used to create the ksuid' do
      time = Time.at(Time.now.to_i)

      ksuid = KSUID.new(time: time)

      expect(ksuid.to_time).to eq(time)
    end
  end

  describe '#to_s' do
    it 'correctly represents the maximum value' do
      expect(KSUID.max.to_s).to eq(KSUID::MAX_STRING_ENCODED)
    end

    it 'correctly represents zero' do
      expected = '0' * 27

      string = KSUID.from_bytes([0] * 20).to_s

      expect(string).to eq(expected)
    end
  end
end
