# frozen_string_literal: true

RSpec.describe KSUID do
  it 'has a version number' do
    expect(KSUID::VERSION).not_to be nil
  end

  describe '.call' do
    it 'returns KSUIDs in tact' do
      ksuid = KSUID.new

      result = KSUID.call(ksuid)

      expect(result).to eq(ksuid)
    end

    it 'converts byte strings to KSUIDs' do
      ksuid = KSUID.new

      result = KSUID.call(ksuid.to_bytes)

      expect(result).to eq(ksuid)
    end

    it 'converts byte arrays to KSUIDs' do
      ksuid = KSUID.new

      result = KSUID.call(ksuid.__send__(:uid))

      expect(result).to eq(ksuid)
    end

    it 'converts base 62 strings to KSUIDs' do
      ksuid = KSUID.new

      result = KSUID.call(ksuid.to_s)

      expect(result).to eq(ksuid)
    end

    it 'returns nil if passed nil' do
      result = KSUID.call(nil)

      expect(result).to be_nil
    end

    it 'raise an ArgumentError upon an unknown value' do
      expect { KSUID.call(1) }.to raise_error(ArgumentError, 'Cannot convert 1 to KSUID')
    end
  end

  describe '.configure' do
    it 'returns a configuration even without a block' do
      expect(KSUID.configure).to be_a(KSUID::Configuration)
    end

    it 'sets configuration values via the block' do
      generator = -> { "\x00" * KSUID::BYTES[:payload] }

      KSUID.configure { |config| config.random_generator = generator }

      expect(KSUID.config.random_generator).to eq(generator)
    end
  end

  describe '.from_base62' do
    it 'converts a base62 KSUID properly' do
      ksuid = KSUID.from_base62(KSUID::MAX_STRING_ENCODED)

      expect(ksuid).to eq(KSUID.max)
    end

    it 'converts a too-short, but correct KSUID' do
      ksuid = KSUID.from_base62('07B4A17')

      expect(ksuid).to eq('0000000000000000000007B4A17')
    end
  end

  describe '.from_bytes' do
    it 'converts a list of bytes' do
      bytes = [
        6, 131, 247, 137, 4, 156, 194, 21, 192, 153,
        212, 43, 120, 77, 190, 153, 52, 27, 215, 156
      ]
      expected = '0vdbMgWkU6slGpLVCqEFwkkZvuW'

      ksuid = KSUID.from_bytes(bytes)

      expect(ksuid).to eq(expected)
    end

    it 'converts a subclass of String' do
      weird = Class.new(String)
      value = weird.new("\x06\x83\xF7\x89\x04\x9C\xC2\x15\xC0\x99\xD4+xM\xBE\x994\e\xD7\x9C")
      expected = '0vdbMgWkU6slGpLVCqEFwkkZvuW'

      ksuid = KSUID.from_bytes(value)

      expect(ksuid).to eq(expected)
    end
  end

  describe '.new' do
    it 'uses the timestamp when specified' do
      payload = "\x00" * 16
      now = Time.parse('2018-06-17 18:00:39 -0500')

      ksuid = KSUID.new(payload: payload, time: now)

      expect(ksuid.raw).to eq('07B49A1700000000000000000000000000000000')
      expect(ksuid.to_s).to eq('16AHMjcX2q0H9rmWgWQwL0hb58q')
      expect(ksuid.to_time).to eq(now)
    end

    it 'defaults the timestamp to now' do
      payload = "\x00" * 16
      now = Time.parse('2018-06-17 18:00:39 -0500')

      Timecop.freeze(now) do
        ksuid = KSUID.new(payload: payload)

        expect(ksuid.raw).to eq('07B49A1700000000000000000000000000000000')
        expect(ksuid.to_s).to eq('16AHMjcX2q0H9rmWgWQwL0hb58q')
        expect(ksuid.to_time).to eq(now)
      end
    end

    context 'with a static random generator' do
      around(:each) do |example|
        original_generator = KSUID.config.random_generator
        KSUID.config.random_generator = -> { "\xFF" * 16 }

        example.run

        KSUID.config.random_generator = original_generator
      end

      it 'generates a payload when one is not given' do
        now = Time.parse('2018-06-17 18:00:39 -0500')

        Timecop.freeze(now) do
          ksuid = KSUID.new

          expect(ksuid.raw).to eq('07B49A17FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')
          expect(ksuid.to_s).to eq('16AHMrPb53GdFLSIQgE57toqmkx')
          expect(ksuid.to_time).to eq(now)
        end
      end
    end
  end
end
