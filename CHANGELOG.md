# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- The ability to configure the random generator for the gem via `KSUID.configure`. This allows you to set up random generation to the specifications you need, whether that is for speed or for security.

## [0.1.0] - 2017-11-05

### Added

- Basic `KSUID.new` interface.
- Parsing of bytes through `KSUID.from_bytes`.
- Parsing of strings through `KSUID.from_base62`.

[0.1.0]: https://github.com/michaelherold/interactor-contracts/tree/v0.1.0
