# frozen_string_literal: true

RSpec.describe KSUID do
  it 'has a version number' do
    expect(KSUID::VERSION).not_to be_nil
  end

  it 'is configurable' do
    generator = -> { "\x00" * KSUID::BYTES[:payload] }

    described_class.configure { |config| config.random_generator = generator }

    expect(described_class.config.random_generator).to eq(generator)
  ensure
    described_class.configure do |config|
      config.random_generator = KSUID::Configuration.default_generator
    end
  end

  describe '.call' do
    it 'returns KSUIDs in tact' do
      ksuid = described_class.new

      result = described_class.call(ksuid)

      expect(result).to eq(ksuid)
    end

    it 'converts byte strings to KSUIDs' do
      ksuid = described_class.new

      result = described_class.call(ksuid.to_bytes)

      expect(result).to eq(ksuid)
    end

    it 'converts byte arrays to KSUIDs' do
      ksuid = described_class.new

      result = described_class.call(ksuid.__send__(:uid))

      expect(result).to eq(ksuid)
    end

    it 'converts base 62 strings to KSUIDs' do
      ksuid = described_class.new

      result = described_class.call(ksuid.to_s)

      expect(result).to eq(ksuid)
    end

    it 'returns nil if passed nil' do
      result = described_class.call(nil)

      expect(result).to be_nil
    end

    it 'raise an ArgumentError upon an unknown value' do
      expect { described_class.call(1) }.to raise_error(ArgumentError)
    end
  end

  describe '.string' do
    it 'uses the current time and a random payload by default' do
      string = described_class.string

      expect(string.length).to eq 27
    end

    it 'accepts a payload and a time' do
      string = described_class.string(
        payload: ("\xFF" * KSUID::BYTES[:payload]),
        time: Time.new(2150, 6, 19, 23, 21, 35, '+00:00')
      )

      expect(string).to eq KSUID::MAX_STRING_ENCODED
    end
  end
end
