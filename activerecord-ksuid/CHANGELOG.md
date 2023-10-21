# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.0.0](https://github.com/michaelherold/ksuid-ruby/compare/v0.5.0...v1.0.0) - 2023-02-25

### Added

- Extracted the ActiveRecord behavior from [`ksuid-v0.5.0`](https://github.com/michaelherold/ksuid-ruby/tree/v0.5.0) into its own gem to slim down the gem and remove unnecessary functionality for people who only want the KSUID functionality.
- Added the ability to disable the automatic generation of KSUIDs for fields by passing `auto_gen: false` to the module builder. This is helpful for foreign key fields, where an invalid value can raise errors, or for cases where you don't want to set the value until a later time.

### Fixed

- Binary KSUIDs on PostgreSQL now correctly deserialize without any extra configuration.
