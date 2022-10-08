# Upgrading instructions for KSUID for Ruby

## v1.0.0

### Extracted `ActiveRecord::KSUID` into its own gem

That KSUID for Ruby included ActiveRecord support directly in its gem has always been a regret of mine. It adds ActiveRecord and Rails concerns to a gem that you can use in any context. It makes running the test suite more complicated for no real gain. And it makes it kludgy to add support for more systems, like Sequel, since you have conflicting concerns in the same gem.

To remove this problem, v1.0.0 extracts the ActiveRecord behavior into its own gem, `activerecord-ksuid`. This version is a straight extraction with an improved test suite so it _should_ mean that the only change you have to make when upgrading from v0.5.0 is to do the following in your Gemfile:

```diff
- gem 'ksuid'
+ gem 'activerecord-ksuid'
```

If you are still on a version prior to v0.5.0, upgrade to that version first, solve the deprecation notice below, ensure your app still works, and then upgrade to v1.0.0.

## v0.5.0

### Deprecated `KSUID::ActiveRecord` in favor of `ActiveRecord::KSUID`

This version deprecates the original constant for the ActiveRecord integration, `KSUID::ActiveRecord`. This change is in preparation for extracting the ActiveRecord integration into its own gem. Continuing to use the original constant will show deprecation warnings upon boot of your application.

Migrating for this version should be quick: simply do a global replace of `KSUID::ActiveRecord` for `ActiveRecord::KSUID`. No other changes should be necessary.

In the future release of v1.0.0, you will need to also include `activerecord-ksuid` your Gemfile. This gem is as-yet unreleased, with a release intended concurrently with v1.0.0 of KSUID for Ruby.
