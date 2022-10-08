# frozen_string_literal: true

RSpec.describe KSUID::Configuration do
  describe '#random_generator' do
    it 'defaults to using secure random' do
      config = described_class.new

      random = config.random_generator.call

      expect(random.size).to eq(16)
    end

    it 'can be overridden with a proper random generator' do
      config = described_class.new
      config.random_generator = -> { Random.new.bytes(16) }

      random = config.random_generator.call

      expect(random.size).to eq(16)
    end

    it 'cannot be overridden by a non-callable' do
      config = described_class.new

      expect { config.random_generator = 'Hello' }.to raise_error(
        KSUID::Configuration::ConfigurationError
      )
    end

    it 'cannot be overriden by a generator of the wrong length' do
      config = described_class.new
      short_generator = -> { Random.new.bytes(5) }

      expect { config.random_generator = short_generator }.to raise_error(
        KSUID::Configuration::ConfigurationError
      )
    end
  end
end
