#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'set'

codes = File.open('day2.txt').readlines.map(&:strip)

two = three = 0

codes.each do |code|
  groups = code.chars.group_by { |c| c }.select { |_, v| v.size > 1 && v.size < 4 }
  two += 1 if groups.any? { |k, v| v.size == 2 }
  three += 1 if groups.any? { |k, v| v.size == 3 }
end

pp two * three

codes.each do |candidate_code|
  codes[(codes.index(candidate_code) + 1)..-1].each do |test_code|
    diff = 0
    (0..candidate_code.length).each { |i| diff += 1 if candidate_code[i] != test_code[i] }

    puts "#{candidate_code}\n#{test_code}" if diff == 1
  end
end
