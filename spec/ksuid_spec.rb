# frozen_string_literal: true

RSpec.describe KSUID do
  it 'has a version number' do
    expect(KSUID::VERSION).not_to be nil
  end

  it 'is configurable' do
    generator = -> { "\x00" * KSUID::BYTES[:payload] }

    KSUID.configure { |config| config.random_generator = generator }

    expect(KSUID.config.random_generator).to eq(generator)
  ensure
    KSUID.configure { |config| config.random_generator = KSUID::Configuration.default_generator }
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
      expect { KSUID.call(1) }.to raise_error(ArgumentError)
    end
  end
end
