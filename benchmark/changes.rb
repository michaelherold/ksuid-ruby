#!/usr/bin/env ruby
# frozen_string_literal: true

# A benchmark that tests the performance of changes in the library
#
# It uses the "hold" system of benchmark-ips, which means that you
# run it once as a baseline, make changes, then run it again to compare

$LOAD_PATH.unshift File.expand_path(__dir__, "../lib")

require 'benchmark/ips'
require 'ksuid'

EXAMPLE = '15Ew2nYeRDscBipuJicYjl970D1'
BINARY_EXAMPLE = ("\xFF" * 20).b

Benchmark.ips do |bench|
  bench.report('baseline') { KSUID::Base62.compatible?(EXAMPLE) }
  bench.report('experiment') { KSUID::Base62.compatible?(EXAMPLE) }

  bench.hold!('changes.jsonld')
  bench.compare!
end
