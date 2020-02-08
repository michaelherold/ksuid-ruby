# frozen_string_literal: true

require "ksuid/activerecord/binary_type"
require "ksuid/activerecord/type"

module KSUID
  # Enables an Active Record model to have a KSUID attribute
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    class_methods do
      def act_as_ksuid(field = :id, opts = {})
        if opts[:binary]
          self.send(:attribute, field.to_sym, :ksuid_binary, default: -> { KSUID.new })
        else
          self.send(:attribute, field.to_sym, :ksuid, default: -> { KSUID.new })
        end

        self.instance_eval do
          define_method "#{field.to_s}_created_at" do
            k = self.send(field)
            return nil unless k
            k.to_time
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, KSUID::ActiveRecordExtension)
