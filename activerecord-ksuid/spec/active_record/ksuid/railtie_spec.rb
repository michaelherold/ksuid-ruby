# frozen_string_literal: true

require 'logger'

begin
  require 'rails'
  require 'active_record'
rescue LoadError
  warn <<~MSG
    Skipping Rails tests because you're not running in Appraisals

    Try running `appraisal rspec` or `appraisal rails-7.0 rspec`
  MSG
  return
end

require 'active_record/ksuid/railtie'

ActiveRecord::KSUID::Railtie.initializers.each(&:run)
ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do
  create_table :events, force: true do |t|
    t.string :ksuid, index: true, unique: true
  end

  create_table :event_primary_keys, force: true, id: false do |t|
    t.ksuid :id, primary_key: true
  end

  create_table :event_binaries, force: true, id: false do |t|
    t.ksuid_binary :id, primary_key: true
  end

  create_table :event_correlations, force: true do |t|
    t.references :from, type: :string, limit: 27, foreign_key: { to_table: :event_primary_keys }
    t.references :to, type: :string, limit: 27, foreign_key: { to_table: :event_primary_keys }
  end

  create_table :event_binary_correlations, force: true do |t|
    t.references :from, type: :binary, limit: 20, foreign_key: { to_table: :event_binaries }
    t.references :to, type: :binary, limit: 20, foreign_key: { to_table: :event_binaries }
  end

  create_table :event_prefixes, force: true, id: false do |t|
    t.ksuid :id, primary_key: true, prefix: 'evt_'
  end
end

# A demonstration model for testing ActiveRecord::KSUID
class Event < ActiveRecord::Base
  include ActiveRecord::KSUID[:ksuid, created_at: true]
end

# A demonstration of KSUIDs as the primary key on a record
class EventPrimaryKey < ActiveRecord::Base
  include ActiveRecord::KSUID[:id]
end

# A demonstration of KSUIDs persisted as binaries
class EventBinary < ActiveRecord::Base
  include ActiveRecord::KSUID[:id, binary: true]
end

# A demonstration of a relation to a string KSUID primary key
class EventCorrelation < ActiveRecord::Base
  include ActiveRecord::KSUID[:from_id]
  include ActiveRecord::KSUID[:to_id]

  belongs_to :from, class_name: 'EventPrimaryKey'
  belongs_to :to, class_name: 'EventPrimaryKey'
end

# A demonstration of a relation to a binary KSUID primary key
class EventBinaryCorrelation < ActiveRecord::Base
  include ActiveRecord::KSUID[:from_id, binary: true]
  include ActiveRecord::KSUID[:to_id, binary: true]

  belongs_to :from, class_name: 'EventBinary'
  belongs_to :to, class_name: 'EventBinary'
end

# A demonstration of a prefixed KSUID
class EventPrefix < ActiveRecord::Base
  include ActiveRecord::KSUID[:id, prefix: 'evt_']
end

RSpec.describe 'ActiveRecord integration', type: :integration do
  context 'with a non-primary field as the KSUID' do
    after { Event.delete_all }

    it 'generates a KSUID upon initialization' do
      event = Event.new

      expect(event.ksuid).to be_a(KSUID::Type)
    end

    it 'restores a KSUID from the database' do
      ksuid = Event.create!.ksuid
      event = Event.last

      expect(event.ksuid).to eq(ksuid)
    end

    it 'can be used as a timestamp for the created_at' do
      event = Event.create!

      expect(event.created_at).not_to be_nil
    end

    it 'can be looked up via a string, byte array, or KSUID', :aggregate_failures do
      id = KSUID.new
      event = Event.create!(ksuid: id)

      expect(Event.find_by(ksuid: id.to_s)).to eq(event)
      expect(Event.find_by(ksuid: id.to_bytes)).to eq(event)
      expect(Event.find_by(ksuid: id)).to eq(event)
    end
  end

  context 'with a primary key field as the KSUID' do
    after { EventPrimaryKey.delete_all }

    it 'generates a KSUID upon initialization' do
      event = EventPrimaryKey.new

      expect(event.id).to be_a(KSUID::Type)
    end
  end

  context 'with a binary KSUID field' do
    after { EventBinary.delete_all }

    it 'generates a KSUID upon initialization' do
      event = EventBinary.new

      expect(event.id).to be_a(KSUID::Type)
    end

    it 'persists the KSUID to the database' do
      event = EventBinary.create

      expect(event.id).to be_a(KSUID::Type)
    end
  end

  context 'with a prefixed KSUID field' do
    after { EventPrefix.delete_all }

    it 'generates a prefixed KSUID upon initialization' do
      event = EventPrefix.new

      expect(event.id).to be_a(KSUID::Prefixed)
    end

    it 'persists the prefixed KSUID to the database' do
      event = EventPrefix.create

      expect(event.id).to be_a(KSUID::Prefixed)
    end

    it 'converts a different prefix into the expected one' do
      event = EventPrefix.create(id: 'cus_2DTtbae0N9LqMntLxfKjh7jS9ak')

      expect(event.id.to_s).to eq('evt_2DTtbae0N9LqMntLxfKjh7jS9ak')
    end
  end

  context 'with a reference to string KSUID-keyed tables' do
    after do
      EventCorrelation.delete_all
      EventPrimaryKey.delete_all
    end

    it 'can relate to the other model', :aggregate_failures do
      event1 = EventPrimaryKey.create!
      event2 = EventPrimaryKey.create!
      correlation = EventCorrelation.create!(from: event1, to: event2)

      correlation.reload

      expect(correlation.from).to eq event1
      expect(correlation.to).to eq event2
    end

    it 'can preload the other model', :aggregate_failures do
      event1 = EventPrimaryKey.create!
      event2 = EventPrimaryKey.create!

      5.times { EventCorrelation.create!(from: event1, to: event2) }

      expect do
        EventCorrelation
          .all
          .map { |correlation| "#{correlation.from.id} #{correlation.to.id}" }
      end.to issue_sql_queries(11)

      expect do
        EventCorrelation
          .includes(:from, :to)
          .map { |correlation| "#{correlation.from.id} #{correlation.to.id}" }
      end.to issue_sql_queries(3)
    end
  end

  context 'with a reference to binary KSUID-keyed tables' do
    after do
      EventBinaryCorrelation.delete_all
      EventBinary.delete_all
    end

    it 'can relate to the other model', :aggregate_failures do
      event1 = EventBinary.create!
      event2 = EventBinary.create!
      correlation = EventBinaryCorrelation.create!(from: event1, to: event2)

      correlation.reload

      expect(correlation.from).to eq event1
      expect(correlation.to).to eq event2
    end

    it 'can preload the other model', :aggregate_failures do
      event1 = EventBinary.create!
      event2 = EventBinary.create!

      5.times { EventBinaryCorrelation.create!(from: event1, to: event2) }

      expect do
        EventBinaryCorrelation
          .all
          .map { |correlation| "#{correlation.from.id} #{correlation.to.id}" }
      end.to issue_sql_queries(11)

      expect do
        EventBinaryCorrelation
          .includes(:from, :to)
          .map { |correlation| "#{correlation.from.id} #{correlation.to.id}" }
      end.to issue_sql_queries(3)
    end
  end

  matcher :issue_sql_queries do |expected|
    supports_block_expectations

    match do |actual|
      @issued_queries = 0
      counter = ->(*) { @issued_queries += 1 }

      ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &actual)

      expected == @issued_queries
    end

    failure_message do
      "expected #{expected} queries, issued #{@issued_queries}"
    end
  end
end
