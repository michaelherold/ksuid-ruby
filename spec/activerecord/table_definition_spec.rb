# frozen_string_literal: true

require 'rails'
require 'active_record'

require 'ksuid/activerecord'
require 'ksuid/activerecord/table_definition'

RSpec.describe KSUID::ActiveRecord::TableDefinition do
  let(:connection) do
    ActiveRecord::Base.sqlite3_connection(
      database: ':memory:',
      adapter: 'sqlite3',
      timeout: 100
    )
  end

  describe '#ksuid' do
    it 'defines a string-serialized KSUID column' do
      connection.create_table(:string_ksuid_events, force: true) do |table|
        table.ksuid :ksuid, index: true, unique: true, null: false
      end

      column = connection.columns('string_ksuid_events').find { |col| col.name == 'ksuid' }

      expect(column.limit).to eq(27)
      expect(column.null).to be(false)
      expect(column.type).to eq(:string)
    end
  end

  describe '#ksuid_binary' do
    it 'defines a string-serialized KSUID column' do
      connection.create_table(:binary_ksuid_events, force: true) do |table|
        table.ksuid_binary :ksuid, index: true, unique: true, null: false
      end

      column = connection.columns('binary_ksuid_events').find { |col| col.name == 'ksuid' }

      expect(column.limit).to eq(20)
      expect(column.null).to be(false)
      expect(column.type).to eq(:binary)
    end
  end

  def with_example_table(definition = nil, table_name = 'ex')
    definition ||=
      <<-SQL
        id integer PRIMARY KEY AUTOINCREMENT,
        number integer
      SQL

    connection.execute("CREATE TABLE #{table_name}(#{definition})")

    yield if block_given?
  ensure
    connection.execute("DROP TABLE #{table_name}")
  end
end
