# frozen_string_literal: true

module Sequel # :nodoc:
  module Plugins # :nodoc:
    # Adds KSUID support to the Sequel ORM
    #
    # @api public
    #
    # @example Creates a model with a standard, string-based KSUID
    #   connection_string = 'sqlite:/'
    #   connection_string = 'jdbc:sqlite::memory:' if RUBY_ENGINE == 'jruby'
    #   DB = Sequel.connect(connection_string)
    #
    #   DB.create_table!(:events) do
    #     Integer :id
    #     String :ksuid
    #   end
    #
    #   class Event < Sequel::Model(:events)
    #     plugin :ksuid
    #   end
    #
    # @example Creates a model with a customized KSUID field
    #   connection_string = 'sqlite:/'
    #   connection_string = 'jdbc:sqlite::memory:' if RUBY_ENGINE == 'jruby'
    #   DB = Sequel.connect(connection_string)
    #
    #   DB.create_table!(:events) do
    #     Integer :id
    #     String :correlation_id
    #   end
    #
    #   class Event < Sequel::Model(:events)
    #     plugin :ksuid, field: :correlation_id
    #   end
    #
    # @example Creates a model that always overwrites the KSUID on save
    #   connection_string = 'sqlite:/'
    #   connection_string = 'jdbc:sqlite::memory:' if RUBY_ENGINE == 'jruby'
    #   DB = Sequel.connect(connection_string)
    #
    #   DB.create_table!(:events) do
    #     Integer :id
    #     String :ksuid
    #   end
    #
    #   class Event < Sequel::Model(:events)
    #     plugin :ksuid, force: true
    #   end
    #
    # @example Creates a model with a binary-encoded KSUID
    #   connection_string = 'sqlite:/'
    #   connection_string = 'jdbc:sqlite::memory:' if RUBY_ENGINE == 'jruby'
    #   DB = Sequel.connect(connection_string)
    #
    #   DB.create_table!(:events) do
    #     Integer :id
    #     blob :ksuid
    #   end
    #
    #   class Event < Sequel::Model(:events)
    #     plugin :ksuid, binary: true
    #   end
    module Ksuid
      # Configures the plugin by setting available options
      #
      # @api private
      #
      # @param model [Sequel::Model] the model to configure
      # @param options [Hash] the hash of available options
      # @option options [Boolean] :binary encode the KSUID as a binary string
      # @option options [Boolean] :field the field to use as a KSUID
      # @option options [Boolean] :force overwrite the field on save
      # @option options [Boolean] :wrap wraps the KSUID into a KSUID type
      # @return [void]
      def self.configure(model, options = OPTS)
        model.instance_exec do
          extract_configuration(options)
          define_ksuid_accessor
        end
      end

      # Class methods that are extended onto an enabling model class
      #
      # @api private
      module ClassMethods
        # The field that is enabled with KSUID handling
        #
        # @api private
        #
        # @return [Symbol]
        attr_reader :ksuid_field

        # Checks whether the KSUID should be binary encoded
        #
        # @api private
        #
        # @return [Boolean]
        def ksuid_binary?
          @ksuid_binary
        end

        # Defines an accessor for the KSUID that converts it into a KSUID
        #
        # @api private
        #
        # @return [void]
        def define_ksuid_accessor
          return unless @ksuid_wrap

          define_ksuid_getter
          define_ksuid_setter
        end

        # Defines a getter for the KSUID that converts it into a KSUID
        #
        # @api private
        #
        # @return [void]
        def define_ksuid_getter
          define_method(@ksuid_field) do
            KSUID.call(super())
          end
        end

        # Defines a setter for the KSUID that converts the value properly
        #
        # @api private
        #
        # @return [void]
        def define_ksuid_setter
          define_method("#{@ksuid_field}=") do |ksuid|
            ksuid = KSUID.call(ksuid)

            if self.class.ksuid_binary?
              super(ksuid.to_bytes)
            else
              super(ksuid.to_s)
            end
          end
        end

        # Extracts all configuration options from the configure step
        #
        # @api private
        #
        # @return [void]
        def extract_configuration(options)
          @ksuid_binary    = options.fetch(:binary, false)
          @ksuid_field     = options.fetch(:field, :ksuid)
          @ksuid_overwrite = options.fetch(:force, false)
          @ksuid_wrap      = options.fetch(:wrap, false)
        end

        # Checks whether the KSUID should be overwritten upon save
        #
        # @api private
        #
        # @return [Boolean]
        def ksuid_overwrite?
          @ksuid_overwrite
        end

        # Checks whether the model should wrap its KSUID field in a type
        #
        # @api private
        #
        # @return [Boolean]
        def ksuid_wrap?
          @ksuid_wrap
        end

        Plugins.inherited_instance_variables(
          self,
          :@ksuid_binary => nil,
          :@ksuid_field => nil,
          :@ksuid_overwrite => nil,
          :@ksuid_wrap => nil
        )
      end

      # Instance methods that are included in an enabling model class
      #
      # @api private
      module InstanceMethods
        # Generates a KSUID for the field before validation
        #
        # @api private
        #
        # @return [void]
        def before_validation
          set_ksuid if new?
          super
        end

        private

        # A hook method for generating a new KSUID
        #
        # @api private
        #
        # @return [String] a binary or base 62-encoded string
        def create_ksuid
          ksuid = KSUID.new

          if self.class.ksuid_binary?
            ksuid.to_bytes
          else
            ksuid.to_s
          end
        end

        # Initializes the KSUID field when it is not set, or overwrites it if enabled
        #
        # Note: The disabled Rubocop rule is to allow the method to follow
        # Sequel conventions.
        #
        # @api private
        #
        # @param ksuid [String] the normal string or byte string of the KSUID
        # @return [void]
        # rubocop:disable Naming/AccessorMethodName
        def set_ksuid(ksuid = create_ksuid)
          field = model.ksuid_field
          setter = :"#{field}="

          return unless respond_to?(field) &&
                        respond_to?(setter) &&
                        (model.ksuid_overwrite? || !get_column_value(field))

          set_column_value(setter, ksuid)
        end
      end
    end
  end
end
