#!/usr/bin/env ruby
# frozen_string_literal: true

require "polyfill-data"
require "benchmark/ips"

puts RUBY_DESCRIPTION

data = Data.define(:a, :b, :c)

Benchmark.ips do |x|
	x.report(".define") { Data.define(:a, :b, :c) }
	x.report("#members") { data.members }
end
