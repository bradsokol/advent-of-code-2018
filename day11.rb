#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

grid_serial_number = 2694

def power_level(x, y, serial_number)
  rack_id = x + 10
  power_level = rack_id * (rack_id * y + serial_number)
  ((power_level / 100) % 10) - 5
end

def total_power_with_cache(grid, x, y, size, cache)
  sum = cache[[x, y, size - 1]]
  (y..(y + size - 1)).each { |j| sum += grid[x + size - 1][j] }
  (x..(x + size - 2)).each { |i| sum += grid[i][y + size - 1] }
  sum
end

def total_power(grid, x, y, size)
  sum = 0
  (x..(x + size - 1)).each { |i| (y..(y + size - 1)).each { |j| sum += grid[i][j] } }
  sum
end

def max_total_power_for_size(grid, size, cache)
  max_location = [-1, -1]
  max_level = -999_999
  (0..(300 - size)).each do |x|
    (0..(300 - size)).each do |y|
      level = if size == 1
        total_power(grid, x, y, size)
      elsif size == 2
        level = total_power(grid, x, y, size)
        cache[[x, y, size]] = level
        level
      else
        level = total_power_with_cache(grid, x, y, size, cache)
        cache[[x, y, size]] = level
        level
      end
      if level > max_level
        max_level = level
        max_location = [x + 1, y + 1]
      end
    end
  end
  [max_location, max_level]
end

grid = Array.new(300)
(0...300).each { |i| grid[i] = Array.new(300) }

(0...300).each { |x| (0...300).each { |y| grid[x][y] = power_level(x + 1, y + 1, grid_serial_number) } }

#pp max_total_power_for_size(grid, 3)[0]

max_location = [-1, -1]
max_level = -999_999
max_size = 0
cache = {}
(1..300).each do |size|
  puts "#{size}..."
  location, level = max_total_power_for_size(grid, size, cache)
  if level > max_level
    max_level = level
    max_location = location
    max_size = size
  end
end

pp max_location
pp max_size
