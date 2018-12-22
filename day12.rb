#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class PottedPlant
  attr_reader :index, :state
  attr_accessor :next, :previous

  def initialize(index, previous, nxt)
    @index = index
    @next = previous
    @previous = nxt
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

def sum_plants(pots, generation)
  sum = 0
  pots.each_with_index { |pot, i| sum += (i - (5 * generation)) if pot == '#' }
  sum
end

file = File.open('day12.txt')
first = last = nil
pots = []
file.readline.match(/initial state: (.+)$/).captures[0].chars.each_with_index do |c, i|
  if c == '#'
    new = PottedPlant.new(i, last, nil)
    last.next = new unless last.nil?
    last = new
    first = new if first.nil?
  end
  pots << c
end
file.readline

transitions = Hash.new('.')
file.readlines.each do |line|
  state, new = line.match(/^(.+) => (.+)$/).captures
  transitions[state] = new
end

sums = [sum_plants(pots, 0)]
diffs = [nil] * 10
buffer = '.....'.chars
new_pots = pots.clone
last_generation = 1.step do |generation|
  pots = buffer + new_pots + buffer
  new_pots = pots.clone
  pots.each_with_index do |pot, i|
    new_pots[i] = transitions[surrounding_state(pots, i)]
  end
  sums[generation] = sum_plants(new_pots, generation)
  diffs.shift
  diffs << sums[generation] - sums[generation - 1]
  break generation if diffs.uniq.size == 1
end

pp sums[20]
pp sums[last_generation] + diffs[0] * (50_000_000_000 - last_generation)
