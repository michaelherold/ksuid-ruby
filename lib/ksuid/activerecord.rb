# frozen_string_literal: true

require 'active_record/ksuid'

module KSUID
  # Enables an Active Record model to have a KSUID attribute
  #
  # @api public
  # @deprecated Use {ActiveRecord::KSUID} instead.
  module ActiveRecord
    # Builds a module to include into the model
    #
    # @api public
    # @deprecated Use {::ActiveRecord::KSUID.[]} instead.
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
    # @param (see ::ActiveRecord::KSUID.[])
    # @return  (see ::ActiveRecord::KSUID.[])
      ActiveSupport::Deprecation.instance.warn(
        'KSUID::ActiveRecord is deprecated! Use ActiveRecord::KSUID instead.',
        caller_locations
      )

      ::ActiveRecord::KSUID[field, created_at: created_at, binary: binary]
    end
  end
end
