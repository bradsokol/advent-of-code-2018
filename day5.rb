#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

def pair?(c1, c2)
  ((c1 >= 'A' && c1 <= 'Z' && c2 >= 'a' && c2 <= 'z') ||
    (c1 >= 'a' && c1 <= 'z' && c2 >= 'A' && c2 <= 'Z')) &&
    c1.downcase == c2.downcase
end

def react(data)
  units = data
  loop do
    new_units = ''
    skip_next = false
    units.chars[0...-1].each_with_index do |c, i|
      if skip_next
        skip_next = false
        next
      end
      if pair?(c, units[i + 1])
        skip_next = true
      else
        new_units += c
        skip_next = false
      end
    end
    new_units += units[-1] unless skip_next
    break if units.length == new_units.length
    units = new_units
  end
  units
end


units = File.open('day5.txt').readlines[0]
# units = 'dabAcCaCBAcCcaDA'
puts react(units).length

lengths = ('A'..'Z').map do |unit|
  printf(unit)
  react(units.gsub(/#{unit}/i, '')).length
end
puts ''

puts lengths.min
puts lengths.index(lengths.min)
