# Upgrading instructions for KSUID for Ruby

## v0.5.0

### Deprecated `KSUID::ActiveRecord` in favor of `ActiveRecord::KSUID`

This version deprecates the original constant for the ActiveRecord integration, `KSUID::ActiveRecord`. This change is in preparation for extracting the ActiveRecord integration into its own gem. Continuing to use the original constant will show deprecation warnings upon boot of your application.

Migrating for this version should be quick: simply do a global replace of `KSUID::ActiveRecord` for `ActiveRecord::KSUID`. No other changes should be necessary.

In the future release of v1.0.0, you will need to also include `activerecord-ksuid` your Gemfile. This gem is as-yet unreleased, with a release intended concurrently with v1.0.0 of KSUID for Ruby.
