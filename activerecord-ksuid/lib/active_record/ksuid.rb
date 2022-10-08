# frozen_string_literal: true

require 'active_record/ksuid/binary_type'
require 'active_record/ksuid/prefixed_type'
require 'active_record/ksuid/type'

# The Ruby on Rails object-relational mapper
#
# @see https://guides.rubyonrails.org/ Ruby on Rails documentation
module ActiveRecord
  # Enables an Active Record model to have a KSUID attribute
  #
  # @api public
  # @since 0.5.0
  module KSUID
    # Builds a module to include into the model
    #
    # @api public
    #
    # @example Add a `#ksuid` attribute to a model
    #   class Event < ActiveRecord::Base
    #     include ActiveRecord::KSUID[:ksuid]
    #   end
    #
    # @example Add a `#remote_id` attribute to a model and overrides `#created_at` to use the KSUID
    #   class Event < ActiveRecord::Base
    #     include ActiveRecord::KSUID[:remote_id, created_at: true]
    #   end
    #
    # @example Add a prefixed `#ksuid` attribute to a model
    #   class Event < ActiveRecord::Base
    #     include ActiveRecord::KSUID[:ksuid, prefix: 'evt_']
    #   end
    #
    # @param field [String, Symbol] the name of the field to use as a KSUID
    # @param created_at [Boolean] whether to override the `#created_at` method
    # @param binary [Boolean] whether to store the KSUID as a binary or a string
    # @param prefix [String, nil] a prefix to prepend to the KSUID attribute
    # @return [Module] the module to include into the model
    def self.[](field, created_at: false, binary: false, prefix: nil)
      raise ArgumentError, 'cannot include a prefix on a binary KSUID' if binary && prefix

      Module.new.tap do |mod|
        if prefix
          define_prefixed_attribute(field, mod, prefix)
        else
          define_attribute(field, mod, binary)
        end
        define_created_at(field, mod) if created_at
      end
    end

    # Defines the attribute method that will be written in the module
    #
    # @api private
    #
    # @param field [String, Symbol] the name of the field to set as an attribute
    # @param mod [Module] the module to extend
    # @param binary [Boolean] whether to store the KSUID as a binary or a string
    # @return [void]
    def self.define_attribute(field, mod, binary)
      type = 'ksuid'
      type = 'ksuid_binary' if binary

      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.included(base)         # def self.included(base)
          base.__send__(                #   base.__send__(
            :attribute,                 #     :attribute,
            :#{field},                  #     :id,
            :#{type},                   #     :ksuid,
            default: -> { ::KSUID.new } #     default: -> { ::KSUID.new }
          )                             #   )
        end                             # end
      RUBY
    end
    private_class_method :define_attribute

    # Defines the attribute method that will be written in the module for a field
    #
    # @api private
    #
    # @param field [String, Symbol] the name of the field to set as an attribute
    # @param mod [Module] the module to extend
    # @param prefix [String] the prefix to add to the KSUID
    # @return [void]
    def self.define_prefixed_attribute(field, mod, prefix)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.included(base)                                 # def self.included(base)
          base.__send__(                                        #   base.__send__(
            :attribute,                                         #     :attribute,
            :#{field},                                          #     :id,
            :ksuid_prefixed,                                    #     :ksuid_prefixed,
            prefix: #{prefix.inspect},                          #     prefix: 'evt_'
            default: -> { ::KSUID.prefixed(#{prefix.inspect}) } #     default: -> { ::KSUID.prefixed('evt_') }
          )                                                     #   )
        end                                                     # end
      RUBY
    end
    private_class_method :define_prefixed_attribute

    # Defines the `#created_at` method that will be written in the module
    #
    # @api private
    #
    # @param field [String, Symbol] the name of the KSUID attribute field
    # @param mod [Module] the module to extend
    # @return [void]
    def self.define_created_at(field, mod)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def created_at           # def created_at
          return unless #{field} #   return unless ksuid

          #{field}.to_time       #   ksuid.to_time
        end                      # end
      RUBY
    end
    private_class_method :define_created_at
  end
end

require 'active_record/ksuid/railtie' if defined?(Rails)
