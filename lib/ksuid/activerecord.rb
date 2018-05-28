# frozen_string_literal: true

require 'ksuid/activerecord/binary_type'
require 'ksuid/activerecord/type'

module KSUID
  # Enables an Active Record model to have a KSUID attribute
  #
  # @api public
  module ActiveRecord
    # Builds a module to include into the model
    #
    # @api public
    #
    # @example Add a `#ksuid` attribute to a model
    #   class Event < ActiveRecord::Base
    #     include KSUID::ActiveRecord[:ksuid]
    #   end
    #
    # @example Add a `#remote_id` attribute to a model and overrides `#created_at` to use the KSUID
    #   class Event < ActiveRecord::Base
    #     include KSUID::ActiveRecord[:remote_id, created_at: true]
    #   end
    #
    # @param field [String, Symbol] the name of the field to use as a KSUID
    # @param created_at [Boolean] whether to override the `#created_at` method
    # @param binary [Boolean] whether to store the KSUID as a binary or a string
    # @return [Module] the module to include into the model
    def self.[](field, created_at: false, binary: false)
      Module
        .new
        .tap do |mod|
          define_attribute(field, mod, binary)
          define_created_at(field, mod) if created_at
        end
    end

    # Defines the attribute method that will be written in the module
    #
    # @api private
    #
    # @param field [String, Symbol] the name of the field to set as an attribute
    # @param mod [Module] the module to extend
    # @return [void]
    def self.define_attribute(field, mod, binary)
      type = 'ksuid'
      type = 'ksuid_binary' if binary

      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.included(base)
          base.__send__(:attribute, :#{field}, :#{type}, default: -> { KSUID.new })
        end
      RUBY
    end
    private_class_method :define_attribute

    # Defines the `#created_at` method that will be written in the module
    #
    # @api private
    #
    # @param field [String, Symbol] the name of the KSUID attribute field
    # @param mod [Module] the module to extend
    # @return [void]
    def self.define_created_at(field, mod)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def created_at
          return unless #{field}

          #{field}.to_time
        end
      RUBY
    end
    private_class_method :define_created_at
  end
end
