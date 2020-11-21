# Upgrading KSUID for breaking changes

## v0.3.0

### ActiveRecord support extracted to a new gem

In order to separate concerns for the gem, all integrations with other systems
--- like ActiveRecord --- will be extracted into integration gems. Specifically
for ActiveRecord, the new gem is call `activerecord-ksuid`.

To add the gem to your Gemfile, add the following line:

    gem 'activerecord-ksuid'

There are a few changes to take into account.

1. Any use of `KSUID::ActiveRecord` should be changed to `ActiveRecord::KSUID`.
   The module builder method works identically, it's only a rename.
2. If you are manually requiring any files (e.g. you use ActiveRecord but not
   Rails), change any manual requires for `ksuid/activerecord/*` to
   `active_record/ksuid/*.
