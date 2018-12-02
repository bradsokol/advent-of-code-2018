#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'set'

deltas = File.open('day1.txt').readlines.map(&:to_i)

frequency = 0
intermediates = Set.new

deltas.each do |delta|
  if intermediates.include?(frequency)
    puts "First duplicate is #{frequency}"
  end
  intermediates.add(frequency)
  frequency += delta
end

puts frequency

i = 0
loop do
  if intermediates.include?(frequency)
    puts "First duplicate is #{frequency}"
    break
  end
  intermediates.add(frequency)
  frequency += deltas[i]
  i = (i + 1) % deltas.length
end
