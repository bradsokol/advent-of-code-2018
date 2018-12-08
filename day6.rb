#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

def distance(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 -  y2).abs
end

def distance_to_all(coordinates, grid, x, y)
  return nil if grid[x][y] > 0
  sum = 0
  coordinates.each do |xx, yy|
    sum += distance(x, y, xx, yy)
  end
  sum
end

def find_closest(coordinates, grid, x, y)
  return nil if grid[x][y] > 0

  min = 999
  closest = 0
  coordinates.each_with_index do |(xx, yy), i|
    d = distance(x, y, xx, yy)
    if d < min
      min = d
      closest = i
    end
  end
  closest
end

def in_region(grid, x, y)
  if x > 0
    return true if grid[x - 1][y] == '#'
  end
  if x < (grid.length - 1)
    return true if grid[x + 1][y] == '#'
  end
  return true if y > 0 && grid[x][y - 1] == '#'
  return true if y < (grid[x-1].length - 1) && grid[x][y + 1] == '#'
  false
end

coordinates = File.open('day6.txt').readlines.map do |line|
  line.match(/(\d+), (\d+)/).captures.map(&:to_i)
end

min_x = coordinates.inject(999) { |min, (x, _)| x < min ? x : min }
max_x = coordinates.inject(0) { |max, (x, _)| x > max ? x : max }
min_y = coordinates.inject(999) { |min, (_, y)| y < min ? y : min }
max_y = coordinates.inject(0) { |max, (_, y)| y > max ? y : max }

coordinates = coordinates.map { |(x, y)| [x - min_x + 1, y - min_y + 1] }
max_x = max_x - min_x + 2
max_y = max_y - min_y + 2

grid = Array.new(max_x)
(0...max_x).each { |i| grid[i] = Array.new(max_y, 0) }

coordinates.each_with_index { |(x, y), i| grid[x][y] = i }

(0...max_x).each do |x|
  (0...max_y).each do |y|
    closest = find_closest(coordinates, grid, x, y)
    grid[x][y] = -closest if closest
  end
end

infinite = []
infinite += grid[0].map(&:abs).uniq
infinite += grid[-1].map(&:abs).uniq
grid.each { |row| infinite += [row[0].abs, row[-1].abs] }
infinite.uniq!

counts = Hash.new(0)
grid.each do |row|
  row.each { |v| counts[v.abs] += 1 unless infinite.include?(v.abs) }
end

max = 0
counts.each { |k, v| max = v if v > max }
puts max

(0...max_x).each do |x|
  (0...max_y).each do |y|
    total_distance = distance_to_all(coordinates, grid, x, y)
    unless total_distance.nil?
      # grid[x][y] = (total_distance >= 32) ? '.' : '#'
      grid[x][y] = (total_distance >= 10_000) ? '.' : '#'
    end
  end
end

count = 0
grid.each_with_index do |row, i|
  row.each_with_index do |v, j|
    if v == '#'
      count += 1
    elsif v.is_a?(Integer) && v > 0 && in_region(grid, i, j)
      count += 1
    end
  end
end
puts count
