# KSUID for Ruby

[![Build Status](https://github.com/michaelherold/ksuid-ruby/workflows/Continuous%20integration/badge.svg)][actions]
[![Test Coverage](https://api.codeclimate.com/v1/badges/94b2a2d4082bff21c10f/test_coverage)][test-coverage]
[![Maintainability](https://api.codeclimate.com/v1/badges/94b2a2d4082bff21c10f/maintainability)][maintainability]
[![Inline docs](http://inch-ci.org/github/michaelherold/ksuid-ruby.svg?branch=master)][inch]

[actions]: https://github.com/michaelherold/ksuid-ruby/actions
[inch]: http://inch-ci.org/github/michaelherold/ksuid-ruby
[maintainability]: https://codeclimate.com/github/michaelherold/ksuid-ruby/maintainability
[test-coverage]: https://codeclimate.com/github/michaelherold/ksuid-ruby/test_coverage

ksuid is a Ruby library that can generate and parse [KSUIDs](https://github.com/segmentio/ksuid). The original readme for the Go version of KSUID does a great job of explaining what they are and how they should be used, so it is excerpted here.

---

# What is a KSUID?

KSUID is for K-Sortable Unique IDentifier. It's a way to generate globally unique IDs similar to RFC 4122 UUIDs, but contain a time component so they can be "roughly" sorted by time of creation. The remainder of the KSUID is randomly generated bytes.

# Why use KSUIDs?

Distributed systems often require unique IDs. There are numerous solutions out there for doing this, so why KSUID?

## 1. Sortable by Timestamp

Unlike the more common choice of UUIDv4, KSUIDs contain a timestamp component that allows them to be roughly sorted by generation time. This is obviously not a strong guarantee as it depends on wall clocks, but is still incredibly useful in practice.

## 2. No Coordination Required

[Snowflake IDs][1] and derivatives require coordination, which significantly increases the complexity of implementation and creates operations overhead. While RFC 4122 UUIDv1 does have a time component, there aren't enough bytes of randomness to provide strong protections against duplicate ID generation.

KSUIDs use 128-bits of pseudorandom data, which provides a 64-times larger number space than the 122-bits in the well-accepted RFC 4122 UUIDv4 standard. The additional timestamp component drives down the extremely rare chance of duplication to the point of near physical infeasibility, even assuming extreme clock skew (> 24-hours) that would cause other severe anomalies.

[1]: https://blog.twitter.com/2010/announcing-snowflake

## 3. Lexicographically Sortable, Portable Representations

The binary and string representations are lexicographically sortable, which allows them to be dropped into systems which do not natively support KSUIDs and retain their k-sortable characteristics.

The string representation is that it is base 62-encoded, so that they can "fit" anywhere alphanumeric strings are accepted.

# How do they work?

KSUIDs are 20-bytes: a 32-bit unsigned integer UTC timestamp and a 128-bit randomly generated payload. The timestamp uses big-endian encoding, to allow lexicographic sorting. The timestamp epoch is adjusted to March 5th, 2014, providing over 100 years of useful life starting at UNIX epoch + 14e8. The payload uses a cryptographically strong pseudorandom number generator.

The string representation is fixed at 27-characters encoded using a base 62 encoding that also sorts lexicographically.

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ksuid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ksuid

## Usage

To generate a KSUID for the present time, use:

```ruby
ksuid = KSUID.new
```

If you need to parse a KSUID from a string that you received, use the conversion method:

```ruby
ksuid = KSUID.from_base62(base62_string)
```

If you need to interpret a series of bytes that you received, use the conversion method:

```ruby
ksuid = KSUID.from_bytes(bytes)
```

The `KSUID.from_bytes` method can take either a byte string or a byte array.

If you need to generate a KSUID for a specific timestamp, use:

```ruby
ksuid = KSUID.new(time: time)  # where time is a Time-like object
```

If you need to use a faster or more secure way of generating the random payloads (or if you want the payload to be non-random data), you can configure the gem for those use cases:

```ruby
KSUID.configure do |config|
  config.random_generator = -> { Random.new.bytes(16) }
end
```

### Prefixed KSUIDs

If you use KSUIDs in multiple contexts, you can prefix them to make them easily identifiable.

```ruby
ksuid = KSUID.prefixed('evt_')
```

Just like a normal KSUID, you can use a specific timestamp:

``` ruby
ksuid = KSUID.prefixed('evt_', time: time)  # where time is a Time-like object
```

You can also parse a prefixed KSUID from a string that you received:

```ruby
ksuid = KSUID::Prefixed.from_base62(base62_string, prefix: 'evt_')
```

Prefixed KSUIDs order themselves with non-prefixed KSUIDs as if their prefix did not exist. With other prefixed KSUIDs, they order first by their prefix, then their timestamp.

### Integrations

KSUID for Ruby can integrate with other systems through adapter gems. Below is a sample of these adapter gems.

#### ActiveRecord

If you want to include KSUID columns in your ActiveRecord models, install the `activerecord-ksuid` gem. If you are using it within a Rails app, run the following:

    bundle add activerecord-ksuid --require active_record/ksuid/railtie
    
If you are using it outside of Rails, add this to your Gemfile:

    gem 'activerecord-ksuid', require: ['ksuid', 'active_record/ksuid', 'active_record/ksuid/table_definition']

See [the readme for the integration](https://github.com/michaelherold/ksuid-ruby/blob/main/activerecord-ksuid/README.md) for more information.

## Contributing

So you’re interested in contributing to KSUID? Check out our [contributing guidelines](CONTRIBUTING.md) for more information on how to do that.

## Supported Ruby Versions

This library aims to support and is [tested against][actions] the following Ruby versions:

* Ruby 2.7
* Ruby 3.0
* Ruby 3.1
* JRuby 9.3

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions, however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or implementation, you may volunteer to be a maintainer. Being a maintainer entails making sure all tests run and pass on that implementation. When something breaks on your implementation, you will be responsible for providing patches in a timely fashion. If critical issues for a particular implementation exist at the time of a major release, support for that Ruby version may be dropped.

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations of this scheme should be reported as bugs. Specifically, if a minor or patch version is released that breaks backward compatibility, that version should be immediately yanked and/or a new version should be immediately released that restores compatibility. Breaking changes to the public API will only be introduced with new major versions. As a result of this policy, you can (and should) specify a dependency on this gem using the [Pessimistic Version Constraint][pessimistic] with two digits of precision. For example:

    spec.add_dependency "ksuid", "~> 0.1"

[pessimistic]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[semver]: http://semver.org/spec/v2.0.0.html

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
