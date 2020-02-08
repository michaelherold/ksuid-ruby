# frozen_string_literal: true

require "rails"
require "active_record"
require "logger"

require "ksuid/activerecord"
require "ksuid/activerecord/table_definition"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do
  create_table :events, force: true do |t|
    t.string :ksuid, index: true, unique: true
  end

  create_table :event_primary_keys, force: true, id: false do |t|
    t.ksuid :id, primary_key: true
  end

  create_table :event_binaries, force: true do |t|
    t.ksuid_binary :ksuid, index: true, unique: true
  end
end

# A demonstration model for testing KSUID::ActiveRecord
class Event < ActiveRecord::Base
  act_as_ksuid :ksuid
end

# A demonstration of KSUIDs as the primary key on a record
class EventPrimaryKey < ActiveRecord::Base
  act_as_ksuid # assumes :id
end

# A demonstration of KSUIDs persisted as binaries
class EventBinary < ActiveRecord::Base
  act_as_ksuid :ksuid, binary: true
end

ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

RSpec.describe "ActiveRecord integration" do
  context "with a non-primary field as the KSUID" do
    after { Event.delete_all }

    it "generates a KSUID upon initialization" do
      event = Event.new

      expect(event.ksuid).to be_a(KSUID::Type)
    end

    it "restores a KSUID from the database" do
      ksuid = Event.create!.ksuid
      event = Event.last

      expect(event.ksuid).to eq(ksuid)
    end

    it "can be used as a timestamp for the created_at" do
      event = Event.create!

      expect(event.ksuid_created_at).not_to be_nil
    end

    it "can be looked up via a string, byte array, or KSUID" do
      id = KSUID.new
      event = Event.create!(ksuid: id)

      expect(Event.find_by(ksuid: id.to_s)).to eq(event)
      expect(Event.find_by(ksuid: id.to_bytes)).to eq(event)
      expect(Event.find_by(ksuid: id)).to eq(event)
    end
  end

  context "with a primary key field as the KSUID" do
    after { EventPrimaryKey.delete_all }

    it "generates a KSUID upon initialization" do
      event = EventPrimaryKey.new

      expect(event.id).to be_a(KSUID::Type)
    end
  end

  context "with a binary KSUID field" do
    after { EventBinary.delete_all }

    it "generates a KSUID upon initialization" do
      event = EventBinary.new

      expect(event.ksuid).to be_a(KSUID::Type)
    end

    it "persists the KSUID to the database" do
      event = EventBinary.create

      expect(event.ksuid).to be_a(KSUID::Type)
    end
  end
end
