# frozen_string_literal: true

RSpec.describe KSUID do
  it 'has a version number' do
    expect(KSUID::VERSION).not_to be nil
  end
end
