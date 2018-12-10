#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class Position
  attr_reader :score
  attr_accessor :clockwise, :counter_clockwise

  def initialize(score, clockwise, counter_clockwise)
    @score = score
    @clockwise = clockwise
    @counter_clockwise = counter_clockwise
  end
end

player_count = 424
last_marble_score = 71_482
last_marble_score = 7_148_200
# player_count = 9
# last_marble_score = 25
players = Array.new(player_count, 0)

current = Position.new(0, nil, nil)
current.clockwise = current.counter_clockwise = current
player = 0
(1..last_marble_score).each do |score|
  if (score % 23) == 0
    players[player] += score
    remove = current
    7.times { remove = remove.counter_clockwise }
    players[player] += remove.score

    current = remove.clockwise
    remove.clockwise.counter_clockwise = remove.counter_clockwise
    remove.counter_clockwise.clockwise = remove.clockwise
  else
    first = current.clockwise
    second = first.clockwise
    new = Position.new(score, second, first)
    first.clockwise = second.counter_clockwise = new
    current = new
  end

  player = (player + 1) % player_count
end

puts players.max
