#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class PottedPlant
  attr_reader :index, :state, :next, :previous

  def initialize(index, previous, next)
    @index = index
    @next = previous
    @previous = next
  end
end

def surrounding_state(pots, i)
  if i == 0
    '..' + pots[0..2].join
  elsif i == 1
    '.' + pots[0..3].join
  elsif i == pots.length - 2
    pots[-4..-1].join + '.'
  elsif i == pots.length - 1
    pots[-3..-1].join + '..'
  else
    pots[(i - 2)..(i + 2)].join
  end
end

file = File.open('day12.txt')
first = last = nil
file.readline.match(/initial state: (.+)$/).captures[0].chars.each_with_index do |c, i|
  if c == '#'
    new = PottedPlant.new(i, last, nil)
    last.next = new unless last.nil?
    last = new
    first = new if first.nil?
  end
end
file.readline

transitions = Hash.new('.')
file.readlines.each do |line|
  state, new = line.match(/^(.+) => (.+)$/).captures
  transitions[state] = new
end

buffer = '.....'.chars
new_pots = pots.clone
20.times do |generation|
  pots = buffer + new_pots + buffer
  new_pots = pots.clone
  pots.each_with_index do |pot, i|
    new_pots[i] = transitions[surrounding_state(pots, i)]
  end
  # puts new_pots[(generation * 5 - 3)..(-1 - (generation * 5 - 3))].join
end

sum = 0
new_pots.each_with_index { |pot, i| sum += (i - 100) if pot == '#' }
pp sum
