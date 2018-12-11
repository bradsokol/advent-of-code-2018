#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class Point
  attr_reader :x, :y

  def initialize(initial_x, initial_y, dx, dy)
    @x = initial_x
    @y = initial_y
    @dx = dx
    @dy = dy
  end

  def move(direction = 1)
    @x += @dx * direction
    @y += @dy * direction
  end
end

def area(points)
  xs = points.map(&:x)
  ys = points.map(&:y)
  (xs.min - xs.max).abs * (ys.min - ys.max).abs
end

points = File.open('day10.txt').readlines.map do |line|
  x, y, dx, dy = line.match(/position=<([ -]\d+), ([ -]\d+)> velocity=<([ -]\d+), ([ -]\d+)>/).captures.map(&:to_i)
  Point.new(x, y, dx, dy)
end

t = 0
current_area = area(points) + 1
loop do
  points.each(&:move)
  new_area = area(points)
  break if new_area > current_area
  current_area = new_area
  t += 1
end

points.each { |point| point.move(-1) }

min_x = points.map(&:x).min
max_x = points.map(&:x).max
min_y = points.map(&:y).min
max_y = points.map(&:y).max

(min_x..max_x).each do |x|
  (min_y..max_y).each do |y|
    printf points.any? { |point| point.x == x && point.y == y } ? '#' : ' '
  end
  puts ''
end
puts t
