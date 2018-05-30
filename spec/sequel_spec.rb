# frozen_string_literal: true

require 'sequel'
require 'sequel/plugins/ksuid'

class << Sequel::Model
  # :reek:Attribute:
  attr_writer :db_schema

  alias orig_columns columns

  # :reek:TooManyStatements:
  def columns(*columns)
    return super if columns.empty?

    define_method(:columns) { columns }
    @dataset.send(:columns=, columns) if @dataset
    def_column_accessor(*columns)
    @columns = columns
    @db_schema = {}

    columns.each { |column| @db_schema[column] = {} }
  end
end

Sequel::Model.use_transactions = false
db = Sequel.mock(fetch: { id: 1, x: 1 }, numrows: 1, autoid: ->(_sql) { 10 })

def db.schema(*)
  [[:id, { primary_key: true }]]
end

def db.reset
  sqls
end

def db.supports_schema_parsing?
  true
end

Sequel::Model.db = DB = db

RSpec.describe Sequel::Plugins::Ksuid do
  let(:alt_ksuid) { '15FZ1XE5JbMLkbeIznyRnUgkuKe' }
  let(:ksuid) { 'aWgEPTl1tmebfsQzFP4bxwgy80V' }

  # Sequel raises many warnings that are outside of the scope of our gem. In
  # order to prevent this output, we silence them around each one of these
  # tests.
  around do |example|
    original = $VERBOSE
    $VERBOSE = nil
    example.run
    $VERBOSE = original
  end

  let(:klass) do
    Class.new(Sequel::Model(:events)) do
      columns :id, :ksuid
      plugin :ksuid

      def _save_refresh(*); end

      define_method(:create_ksuid) { KSUID.max.to_s }

      db.reset
    end
  end

  it 'handles validations on the KSUID field for new objects' do
    klass.plugin :ksuid, force: true
    instance = klass.new

    # :reek:DuplicateMethodCall
    def instance.validate
      errors.add(model.ksuid_field, 'not present') unless send(model.ksuid_field)
    end

    expect(instance).to be_valid
  end

  it 'sets the KSUID field when skipping validations' do
    klass.plugin :ksuid

    klass.new.save(validate: false)

    expect(klass.db.sqls).to eq(["INSERT INTO events (ksuid) VALUES ('#{ksuid}')"])
  end

  it 'sets the KSUID field on creation' do
    instance = klass.create

    expect(klass.db.sqls).to eq(["INSERT INTO events (ksuid) VALUES ('#{ksuid}')"])
    expect(instance.ksuid).to eq(ksuid)
  end

  it 'allows specifying the KSUID field via the :field option' do
    klass =
      Class.new(Sequel::Model(:events)) do
        columns :id, :k
        plugin :ksuid, field: :k
        def _save_refresh(*); end
      end

    instance = klass.create

    expect(klass.db.sqls).to eq(["INSERT INTO events (k) VALUES ('#{instance.k}')"])
  end

  it 'does not raise an error if the model does not have the KSUID column' do
    klass.columns :id, :x
    klass.send(:undef_method, :ksuid)

    klass.create(x: 2)
    klass.load(id: 1, x: 2).save

    expect(klass.db.sqls).to(
      eq(['INSERT INTO events (x) VALUES (2)', 'UPDATE events SET x = 2 WHERE (id = 1)'])
    )
  end

  it 'overwrites an existing KSUID if the :force option is used' do
    klass.plugin :ksuid, force: true

    instance = klass.create(ksuid: alt_ksuid)

    expect(klass.db.sqls).to eq(["INSERT INTO events (ksuid) VALUES ('#{ksuid}')"])
    expect(instance.ksuid).to eq(ksuid)
  end

  it 'works with subclasses' do
    new_klass = Class.new(klass)

    instance = new_klass.create

    expect(instance.ksuid).to eq(ksuid)
    expect(new_klass.db.sqls).to eq(["INSERT INTO events (ksuid) VALUES ('#{ksuid}')"])

    second_instance = new_klass.create(ksuid: alt_ksuid)

    expect(second_instance.ksuid).to eq(alt_ksuid)

    new_klass.class_eval do
      columns :id, :k
      plugin :ksuid, field: :k, force: true
    end

    second_klass = Class.new(new_klass)
    second_klass.db.reset

    instance = second_klass.create

    expect(instance.k).to eq(ksuid)
    expect(second_klass.db.sqls).to eq(["INSERT INTO events (k) VALUES ('#{ksuid}')"])
  end

  it 'generates a binary KSUID when told to do so' do
    klass =
      Class.new(Sequel::Model(:events)) do
        columns :id, :ksuid
        plugin :ksuid, binary: true
        def _save_refresh(*); end
      end

    instance = klass.create

    expect(instance.ksuid).not_to be_nil
    expect(KSUID::Base62.compatible?(instance.ksuid)).to eq(false)
    expect(klass.db.sqls).to(
      eq(["INSERT INTO events (ksuid) VALUES ('#{instance.ksuid}')"])
    )
  end

  it 'converts the KSUID field into a KSUID when told to do so' do
    klass =
      Class.new(Sequel::Model(:events)) do
        columns :id, :ksuid
        plugin :ksuid, wrap: true
        def _save_refresh(*); end
      end

    instance = klass.create

    expect(instance.ksuid).to be_a(KSUID::Type)

    instance.ksuid = KSUID.new.to_bytes
    instance.save

    expect(instance.ksuid).to be_a(KSUID::Type)
  end

  describe '.ksuid_field' do
    it 'introspects the KSUID field' do
      expect(klass.ksuid_field).to eq(:ksuid)

      klass.plugin :ksuid, field: :alt_ksuid

      expect(klass.ksuid_field).to eq(:alt_ksuid)
    end
  end

  describe '.ksuid_overwrite?' do
    it 'introspects the overwriting ability' do
      expect(klass.ksuid_overwrite?).to eq(false)

      klass.plugin :ksuid, force: true

      expect(klass.ksuid_overwrite?).to eq(true)
    end
  end
end
