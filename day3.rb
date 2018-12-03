#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

fabric = Array.new(1100)
1100.times { |i| fabric[i] = Array.new(1100, 0) }

File.open('day3.txt').readlines.each do |claim|
  claim_id, x, y, width, height = claim.match(/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/).captures.map(&:to_i)

  (x..(x + width - 1)).each do |i|
    (y..(y + height - 1)).each do |j|
      fabric[i][j] = fabric[i][j] == 0 ? claim_id : '#'
    end
  end
end

puts fabric.map { |row| row.count { |cell| cell == '#' } }.sum

File.open('day3.txt').readlines.each do |claim|
  claim_id, x, y, width, height = claim.match(/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/).captures.map(&:to_i)

  count = 0
  (x..(x + width - 1)).each do |i|
    (y..(y + height - 1)).each do |j|
      count += 1 if fabric[i][j] == claim_id
    end
  end
  puts claim_id if count == width * height
end
