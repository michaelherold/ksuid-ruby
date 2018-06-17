# frozen_string_literal: true

require 'rails'
require 'active_record'

require 'ksuid/activerecord'

RSpec.describe KSUID::ActiveRecord::BinaryType do
  subject(:type) { described_class.new }

  describe '#cast' do
    it 'returns nil when given nil' do
      expect(type.cast(nil)).to be(nil)
    end

    it 'converts to a KSUID' do
      expect(type.cast("\xFF" * 20)).to eq(KSUID.max)
    end
  end

  describe '#deserialize' do
    it 'returns nil when given nil' do
      expect(type.deserialize(nil)).to be(nil)
    end

    it 'converts to a KSUID' do
      value = ActiveRecord::Type::Binary::Data.new(KSUID.max.to_bytes)
      weird_type = Class.new(ActiveRecord::Type::Binary::Data)
      other_value = weird_type.new(KSUID.max.to_bytes)

      expect(type.deserialize(value)).to eq(KSUID.max)
      expect(type.deserialize(other_value)).to eq(KSUID.max)
      expect(type.deserialize(KSUID.max.to_bytes)).to eq(KSUID.max)
      expect(type.deserialize(KSUID.max.to_bytes.bytes)).to eq(KSUID.max)
    end
  end

  describe '#serialize' do
    it 'returns nil when given nil' do
      expect(type.serialize(nil)).to be(nil)
    end

    it 'converts to a binary-encoded KSUID' do
      max_value = [255] * 20

      expect(type.serialize(KSUID.max)).to be_an(ActiveModel::Type::Binary::Data)
      expect(type.serialize(KSUID.max).to_s.bytes).to eq(max_value)
      expect(type.serialize(KSUID.max.to_bytes).to_s.bytes).to eq(max_value)
      expect(type.serialize(KSUID::MAX_STRING_ENCODED).to_s.bytes).to eq(max_value)
    end
  end

  describe '#type' do
    subject { type.type }

    it { is_expected.to eq(:ksuid_binary) }
  end
end
