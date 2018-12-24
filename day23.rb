#! /usr/bin/env ruby

# frozen_string_literal: true

class Nanobot
  attr_reader :x, :y, :z, :r

  def initialize(x, y, z, r)
    @x = x
    @y = y
    @z = z
    @r = r
  end

  def distance_to(other)
    (x - other.x).abs + (y - other.y).abs + (z - other.z).abs
  end
end

class Intersection
  attr_accessor :x, :dx, :y, :dy, :z, :dz
  attr_reader :n

  def initialize(x, y, z, r)
    @n = 1
  end

  def intersects?(bot)
    x_intersects?(bot) || y_intersects?(bot) || z_intersects?(bot)
  end

  def merge(bot)
    return unless intersects?(bot)
    n += 1
  end

  private
end

nanobots = File.open('day23.txt').readlines.map do |line|
  x, y, z, r = line.match(/^pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)$/).captures.map(&:to_i)
  Nanobot.new(x, y, z, r)
end

largest_r = nanobots.max { |a, b| a.r <=> b.r }

puts nanobots.count { |bot| largest_r.distance_to(bot) <= largest_r.r }
