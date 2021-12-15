# frozen_string_literal: true

# A benchmark that tests different ways to ensure a string matches
# only characters from the KSUID Base62 charset.

require 'benchmark/ips'
require 'set'

EXAMPLE = '15Ew2nYeRDscBipuJicYjl970D1'
CHARSET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
CHARSET_SET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split.to_set
MATCHER = /[^#{CHARSET}]/
CHARS   = CHARSET.chars

# Uses a two-finger method to check each character against each charset member
# exactly once
def two_finger(example)
  example = example.chars.sort
  left, right = [0, 0]

  while left < example.length && right < CHARSET.length do
    if example[left] == CHARSET[right]
      left += 1
    else
      right += 1
    end
  end

  left == example.length &&
    example[left - 1] == CHARSET[right]
end

Benchmark.ips do |bench|
  bench.report('include?') { EXAMPLE.each_char.all? { |c| CHARSET.include? c } }
  bench.report('include? optimized') { EXAMPLE.each_char.all? { |c| CHARSET_SET.include?(c) } }
  bench.report('Regexp#match?') { !CHARSET.match?(EXAMPLE) }
  bench.report('Regexp#match? - commit cac33be') { EXAMPLE.each_char.all? { |c| !CHARSET.match?(MATCHER) } }
  bench.report('Array#-') { EXAMPLE.split('') - CHARS }
  bench.report('two finger') { two_finger(EXAMPLE) }

  bench.compare!
end
