#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark/ips'
require 'json'
require 'ksuid'

RESULTS_FILE = '.random_generator.json'
NON_RANDOM_DATA = "\x00" * 16

3.times do
  if File.exist?(RESULTS_FILE)
    results = File.readlines(RESULTS_FILE).map { |line| JSON.parse(line)['item'] }

    if !results.include?('random')
      generator = Random.new
      KSUID.configure { |config| config.random_generator = -> { generator.bytes(16) } }
    else
      KSUID.configure { |config| config.random_generator = -> { NON_RANDOM_DATA } }
    end
  end

  Benchmark.ips do |x|
    x.report('securerandom') { KSUID.new }
    x.report('random') { KSUID.new }
    x.report('non-random') { KSUID.new }

    x.compare!
    x.hold!(RESULTS_FILE)
  end
end
