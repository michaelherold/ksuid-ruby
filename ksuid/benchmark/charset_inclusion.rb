# frozen_string_literal: true

# A benchmark that tests different ways to ensure a string matches
# only characters from the KSUID Base62 charset.

require 'benchmark/ips'
require 'set'

EXAMPLE = '15Ew2nYeRDscBipuJicYjl970D1'
BAD_EXAMPLE = '15Ew2nYeRDscBipuJicYjl970D!'
CHARSET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
MATCHER = /[^#{CHARSET}]/
CHARS   = CHARSET.chars
SET     = Set.new(CHARS)

# Checks each char individually against the charset
def include?(example)
  example.each_char.all? { |c| CHARSET.include?(c) }
end

# Checks for a match against anything not in the charset
def regexp_match?(example)
  !MATCHER.match?(example)
end

# Checks each character against the regexp
def match_by_char?(example)
  example.each_char.all? { |c| !MATCHER.match?(c) }
end

# Splits the string and uses array difference to check for stray characters
def split_diff(example)
  (example.split('') - CHARS).empty?
end

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

def set_include?(example)
  example.each_char.all? { |c| SET.include?(c) }
end

include?(EXAMPLE) or raise "include? does not work"
regexp_match?(EXAMPLE) or raise "regexp_match? does not work"
match_by_char?(EXAMPLE) or raise "match_by_char? does not work"
split_diff(EXAMPLE) or raise "split_diff does not work"
two_finger(EXAMPLE) or raise "two_finger does not work"
set_include?(EXAMPLE) or raise "set_include? does not work"

include?(BAD_EXAMPLE) and raise "include? does not work"
regexp_match?(BAD_EXAMPLE) and raise "regexp_match? does not work"
match_by_char?(BAD_EXAMPLE) and raise "match_by_char? does not work"
split_diff(BAD_EXAMPLE) and raise "split_diff does not work"
two_finger(BAD_EXAMPLE) and raise "two_finger does not work"
set_include?(BAD_EXAMPLE) and raise "set_include? does not work"

puts "Benchmarking good example\n\n"

Benchmark.ips do |bench|
  bench.report('include?') { include?(EXAMPLE) }
  bench.report('Regexp#match?') { regexp_match?(EXAMPLE) }
  bench.report('#match?(char)') { match_by_char?(EXAMPLE) }
  bench.report('Array#-') { split_diff(EXAMPLE) }
  bench.report('two finger') { two_finger(EXAMPLE) }
  bench.report('Set#include?') { set_include?(EXAMPLE) }

  bench.compare!
end

puts "Benchmarking bad example\n\n"

Benchmark.ips do |bench|
  bench.report('include?') { include?(BAD_EXAMPLE) }
  bench.report('Regexp#match?') { regexp_match?(BAD_EXAMPLE) }
  bench.report('#match?(char)') { match_by_char?(BAD_EXAMPLE) }
  bench.report('Array#-') { split_diff(BAD_EXAMPLE) }
  bench.report('two finger') { two_finger(BAD_EXAMPLE) }
  bench.report('Set#include?') { set_include?(BAD_EXAMPLE) }

  bench.compare!
end
