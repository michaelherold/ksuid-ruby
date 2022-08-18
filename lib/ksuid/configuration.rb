# frozen_string_literal: true

require 'securerandom'

module KSUID
  # Encapsulates the configuration for the KSUID gem as a whole.
  #
  # You can override the generation of the random payload data by setting the
  # {#random_generator} value to a valid random payload generator. This should
  # be done via the module-level {KSUID.configure} method.
  #
  # The gem-level configuration lives at the module-level {KSUID.config}.
  #
  # @api semipublic
  class Configuration
    # Raised when the gem is misconfigured.
    ConfigurationError = Class.new(StandardError)

    # The default generator for generating random payloads
    #
    # @api private
    #
    # @return [Proc]
    def self.default_generator
      -> { SecureRandom.random_bytes(BYTES[:payload]) }
    end

    # Instantiates a new KSUID configuration
    #
    # @api private
    #
    # @return [KSUID::Configuration] the new configuration
    def initialize
      self.random_generator = self.class.default_generator
    end

    # The method for generating random payloads in the gem
    #
    # @api private
    #
    # @return [#call] a callable that returns 16 bytes
    attr_reader :random_generator

    # Override the method for generating random payloads in the gem
    #
    # @api semipublic
    #
    # @example Override the random generator with a null data generator
    #   KSUID.configure do |config|
    #     config.random_generator = -> { "\x00" * KSUID::BYTES[:payload] }
    #   end
    #
    # @example Override the random generator with the faster, but less secure, Random
    #   KSUID.configure do |config|
    #     config.random_generator = -> { Random.new.bytes(KSUID::BYTES[:payload]) }
    #   end
    #
    # @param generator [#call] a callable that returns 16 bytes
    # @return [#call] a callable that returns 16 bytes
    def random_generator=(generator)
      assert_generator_is_callable(generator)
      assert_payload_size(generator)

      @random_generator = generator
    end

    private

    # Raises an error if the assigned generator is not callable
    #
    # @api private
    #
    # @raise [ConfigurationError] if the generator is not callable
    # @return [nil]
    def assert_generator_is_callable(generator)
      return if generator.respond_to?(:call)

      raise ConfigurationError, "Random generator #{generator} is not callable"
    end

    # Raises an error if the assigned generator generates the wrong size
    #
    # @api private
    #
    # @raise [ConfigurationError] if the generator generates the wrong size payload
    # @return [nil]
    def assert_payload_size(generator)
      return if (length = generator.call.length) == (expected_length = BYTES[:payload])

      raise(
        ConfigurationError,
        'Random generator generates the wrong number of bytes ' \
        "(#{length} generated, #{expected_length} expected)"
      )
    end
  end
end
