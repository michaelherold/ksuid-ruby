# Upgrading instructions for KSUID for ActiveRecord

## v1.0.0

This is the initial release of this library. If you are upgrading from KSUID for Ruby 0.x, follow the notice below.

### Extracted `ActiveRecord::KSUID` into its own gem

That KSUID for Ruby included ActiveRecord support directly in its gem has always been a regret of mine. It adds ActiveRecord and Rails concerns to a gem that you can use in any context. It makes running the test suite more complicated for no real gain. And it makes it kludgy to add support for more systems, like Sequel, since you have conflicting concerns in the same gem.

To remove this problem, v1.0.0 extracts the ActiveRecord behavior into its own gem, `activerecord-ksuid`. This version is a straight extraction with an improved test suite so it _should_ mean that the only change you have to make when upgrading from v0.5.0 is to do the following in your Gemfile:

```diff
- gem 'ksuid'
+ gem 'activerecord-ksuid'
```

If you are still on a version of KSUID for Ruby prior to v0.5.0, upgrade to that version first, solve the deprecation notice below, ensure your app still works, and then upgrade to v1.0.0.
