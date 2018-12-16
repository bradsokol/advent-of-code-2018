#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class Unit
  attr_reader :hit_points, :strength, :index, :species

  def initialize(species, index, x, y)
    @species = species
    @index = index
    @x = x
    @y = y
  end

  def coordinate
    [@x, @y]
  end
end

def before?(coordinate1, coordinate2)
  coordinate1.y == coordinate2.y ? coordinate1.x < coordinate2.x : coordinate1.y < coordinate2.y
end

def in_range(targets)
  targets.each_with_object([]) do |target, memo|
    unoccupied_positions(target.coordinate) { |position| memo << position }
  end
end

def order_units!
  $units.sort! { |a, b| a.y == b.y ? a.x <=> b.x : a.y <=> b.y }
end

def shortest_distance(x1, y1, x2, y2)
  target = [x2, y2]
  queue = Queue.new
  unoccupied_positions([x1, y1]).each { |position| queue.push([position, 1]) }
  visited = Set.new
  until queue.empty? do
    position, distance = queue.pop
    return distance if target == position
    visited << position

    unoccupied_positions(position).each { |p| queue.push(p, distance + 1) unless visited.include?(p) }
  end
  nil
end

def distances(unit, positions)
  positions.map { |position| shortest_distance(unit.x, unit.y, position[0], position[1]) }
end

def targets(unit)
  target_species = unit.species == :elf ? :goblin : :elf
  $units.select { |u| u.species == target_species }
end

def unoccupied_positions(coordinate)
  x, y = coordinate
  if y > 0 && $cave[y - 1][x] == '.'
    yield [x, y - 1]
  end
  if x < $cave[0].length - 2 && $cave[y][x + 1] == '.'
    yield [x + 1, y]
  end
  if y < $cave.length - 2 && $cave[x][y + 1] == '.'
    yield [x, y + 1]
  end
  if x > 0 && $cave[x - 1][y] == '.'
    yield [x - 1, y]
  end
end

$cave = []
$units = []
e = g = 0
File.open('day15.txt').readlines.each_with_index do |line, j|
  $cave[j] = line.chars
  $cave[j].each_with_index do |position, i|
    if position == 'E'
      $units << Unit.new(:elf, e, i, j)
      e += 1
    elsif position == 'G'
      $units << Unit.new(:goblin, -g, i, j)
      g += 1
    end
    $cave[j][i] = $units[-1].index if position == 'E' || position == 'G'
  end
end
