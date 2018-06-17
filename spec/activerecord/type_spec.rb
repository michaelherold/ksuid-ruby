# frozen_string_literal: true

require 'rails'
require 'active_record'

require 'ksuid/activerecord'

RSpec.describe KSUID::ActiveRecord::Type do
  subject(:type) { described_class.new }

  describe '#cast' do
    it 'returns nil when given nil' do
      expect(type.cast(nil)).to be(nil)
    end

    it 'converts to a KSUID' do
      expect(type.cast(KSUID::MAX_STRING_ENCODED)).to eq(KSUID.max)
    end
  end

  describe '#deserialize' do
    it 'returns nil when given nil' do
      expect(type.deserialize(nil)).to be(nil)
    end

    it 'converts to a KSUID' do
      expect(type.deserialize(KSUID::MAX_STRING_ENCODED)).to eq(KSUID.max)
    end
  end

  describe '#serialize' do
    it 'returns nil when given nil' do
      expect(type.serialize(nil)).to be(nil)
    end

    it 'converts to a string-encoded KSUID' do
      expect(type.serialize(KSUID.max)).to be_a(String)
      expect(type.serialize(KSUID.max)).to eq(KSUID::MAX_STRING_ENCODED)
      expect(type.serialize(KSUID.max.to_bytes)).to eq(KSUID::MAX_STRING_ENCODED)
      expect(type.serialize(KSUID::MAX_STRING_ENCODED)).to eq(KSUID::MAX_STRING_ENCODED)
    end
  end

  describe '#type' do
    subject { type.type }

    it { is_expected.to eq(:ksuid) }
  end
end
