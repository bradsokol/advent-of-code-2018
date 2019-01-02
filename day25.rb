#! /usr/bin/env ruby

require 'pp'
require 'pry'

def distance(a, b)
  (a[0] - b[0]).abs + (a[1] - b[1]).abs + (a[2] - b[2]).abs + (a[3] - b[3]).abs
end

$points = {}
File.open('day25-sample3.txt').readlines.each do |line|
  point = line.match(/(-?\d+),(-?\d+),(-?\d+),(-?\d+)/).captures.map(&:to_i)
  $points[point] = []
end

keys = $points.keys
keys.each_with_index do |point, i|
  keys.each do |other|
    $points[keys[i]] << other if distance(point, other) <= 3
  end
end
pp $points

$memo = Marshal.load(Marshal.dump($points))

$constellations = []
$points.each do |point, adjacent|
  c = $constellations.find { |c| c.include?(point) }
  if c
    c << point
    c += adjacent
    next
  end

  cc = nil
  adjacent.each do |a|
    cc = $constellations.find { |c| c.include?(a) }
    break if cc
  end
  if cc
    cc << point
    cc += adjacent
  else
    $constellations << (adjacent << point)
  end
end
pp $constellations
p $constellations.count

# def clear(points)
#   points.each do |point|
#     if $memo.key?(point)
#       adjacent = $memo[point]
#       $memo.delete(point)
#       clear(adjacent)
#     end
#   end
# end

# count = 0
# $points.each do |point, adjacent|
#   if $memo.key?(point)
#     clear([point])
#     count += 1
#   end
# end
# p count
