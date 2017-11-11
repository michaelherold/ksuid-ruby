# frozen_string_literal: true

RSpec.describe KSUID do
  it 'has a version number' do
    expect(KSUID::VERSION).not_to be nil
  end

  it 'is configurable' do
    generator = -> { "\x00" * KSUID::BYTES[:payload] }

    KSUID.configure { |config| config.random_generator = generator }

    expect(KSUID.config.random_generator).to eq(generator)
  end
end
