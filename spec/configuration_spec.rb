# frozen_string_literal: true

RSpec.describe KSUID::Configuration do
  describe '#random_generator' do
    it 'uses to the default generator when not set' do
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
        KSUID::Configuration::ConfigurationError,
        'Random generator Hello is not callable'
      )
    end

    it 'cannot be overriden by a generator of the wrong length' do
      config = described_class.new
      short_generator = -> { [0, 0, 0, 0, 0] }

      expect { config.random_generator = short_generator }.to raise_error(
        KSUID::Configuration::ConfigurationError,
        'Random generator generates the wrong number of bytes (5 generated, 16 expected)'
      )
    end
  end
end
