# frozen_string_literal: true

module KSUID
  # Enables the usage of KSUID types within ActiveRecord when Rails is loaded
  #
  # @api private
  class Railtie < ::Rails::Railtie
    initializer 'ksuid' do
      ActiveSupport.on_load :active_record do
        require 'ksuid/activerecord'
        require 'ksuid/activerecord/table_definition'
      end
    end
  end
end
