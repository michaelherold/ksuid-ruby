# frozen_string_literal: true

RSpec.describe KSUID::Prefixed do
  describe 'value object semantics' do
    it 'uses value comparison instead of identity comparison' do
      ksuid1 = KSUID.prefixed('evt_')
      ksuid2 = ksuid1.dup
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

  describe '.call' do
    it 'returns same-prefixed KSUIDs in tact' do
      ksuid = KSUID.new

      result = KSUID.call(ksuid)

      expect(result).to eq(ksuid)
    end

    it 'prefixes KSUIDs' do
      ksuid = KSUID.new

      result = described_class.call(ksuid, prefix: 'evt_')

      expect(result.to_s).to eq("evt_#{ksuid}")
    end

    it 'raises for byte strings' do
      ksuid = KSUID.prefixed('evt_')

      expect { described_class.call(ksuid.to_bytes, prefix: 'evt_') }
        .to raise_error(ArgumentError)
    end

    it 'raises for byte arrays' do
      ksuid = KSUID.prefixed('evt_')

      expect { described_class.call(ksuid.__send__(:uid), prefix: 'evt_') }
        .to raise_error(ArgumentError)
    end

    it 'converts base 62 strings to KSUIDs' do
      ksuid = KSUID.new

      result = described_class.call(ksuid.to_s, prefix: 'cus_')

      expect(result.to_s).to eq("cus_#{ksuid}")
    end

    it 'returns nil if passed nil' do
      result = described_class.call(nil, prefix: 'evt_')

      expect(result).to be_nil
    end

    it 'raise an ArgumentError upon an unknown value' do
      expect { described_class.call(1, prefix: 'evt_') }
        .to raise_error(ArgumentError)
    end
  end

  describe '#<=>' do
    it 'does not sort with non-KSUIDs' do
      ksuid = KSUID.prefixed('evt_')

      expect(ksuid <=> ksuid.to_s).to be_nil
    end

    it 'sorts with un-prefixed KSUIDs by time' do
      ksuid1 = KSUID.prefixed('evt_', time: Time.parse('2022-08-16 11:00:00 UTC'))
      ksuid2 = KSUID.new(time: Time.parse('2022-08-16 10:00:00 UTC'))
      ksuid3 = KSUID.new(time: Time.parse('2022-08-16 12:00:00 UTC'))

      sorted = [ksuid1, ksuid2, ksuid3].sort

      expect(sorted).to eq([ksuid2, ksuid1, ksuid3])
    end

    it 'sorts with prefixed KSUIDs by prefix, then time' do
      ksuid1 = KSUID.prefixed('evt_', time: Time.parse('2022-08-16 11:00:00 UTC'))
      ksuid2 = KSUID.prefixed('evt_', time: Time.parse('2022-08-16 10:00:00 UTC'))
      ksuid3 = KSUID.prefixed('cus_', time: Time.parse('2022-08-16 12:00:00 UTC'))

      sorted = [ksuid1, ksuid2, ksuid3].sort

      expect(sorted).to eq([ksuid3, ksuid2, ksuid1])
    end
  end

  describe '#==' do
    it 'requires a prefixed KSUID' do
      ksuid1 = KSUID.prefixed('evt_', time: Time.parse('2022-08-16 11:00:00 UTC'))
      ksuid2 = KSUID.call(ksuid1)

      expect(ksuid1).not_to eq(ksuid2)
    end

    it 'checks the prefix as well as the uid', :aggregate_failures do
      ksuid1 = KSUID.prefixed('evt_', time: Time.parse('2022-08-16 11:00:00 UTC'))
      ksuid2 = described_class.call(ksuid1, prefix: 'evt_')
      ksuid3 = described_class.call(ksuid1, prefix: 'cus_')

      expect(ksuid1).to eq(ksuid2)
      expect(ksuid1).not_to eq(ksuid3)
    end
  end

  describe '#raw' do
    it 'prefixes the original KSUID payload' do
      ksuid = described_class.from_base62('evt_0vdbMgWkU6slGpLVCqEFwkkZvuW', prefix: 'evt_')

      expect(ksuid.raw).to eq('evt_0683F789049CC215C099D42B784DBE99341BD79C')
    end
  end
end
