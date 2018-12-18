#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry-byebug'
require 'set'

class Coordinate
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    other.class == self.class && other.state == state
  end
  alias_method :eql?, :==

  def hash
    state.hash
  end

  protected

  def state
    [x, y]
  end
end

class Unit
  attr_reader :hit_points, :strength, :index, :species, :coordinate

  def initialize(species, index, x, y)
    @species = species
    @index = index
    @coordinate = Coordinate.new(x, y)
  end

  def x
    coordinate.x
  end

  def y
    coordinate.y
  end

  def move_to(position)
    @coordinate = Coordinate.new(position.x, position.y)
  end
end

def print_cave
  puts ''
  $cave.each do |row|
    row.each do |position|
      # printf position.to_s
      if position == '.' || position == '#' || position == "\n"
        printf position
      elsif position > 0
        printf 'E'
      else
        printf 'G'
      end
    end
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

def shortest_distance(coordinate, target)
  queue = Queue.new
  unoccupied_positions(coordinate) { |position| queue.push([position, 1]) }
  visited = Set.new
  until queue.empty? do
    position, distance = queue.pop
    return distance if target == position
    visited << position

    unoccupied_positions(position) { |p| queue.push([p, distance + 1]) unless visited.include?(p) }
  end
  nil
end

def distances(unit, positions)
  positions.map { |position| shortest_distance(unit.x, unit.y, position.x, position.y) }
end

def targets(unit)
  target_species = unit.species == :elf ? :goblin : :elf
  $units.select { |u| u.species == target_species }
end

def unoccupied_positions(coordinate)
  if coordinate.y > 0 && $cave[coordinate.y - 1][coordinate.x] == '.'
    yield Coordinate.new(coordinate.x, coordinate.y - 1 )
  end
  if coordinate.x < $cave[0].length - 2 && $cave[coordinate.y][coordinate.x + 1] == '.'
    yield Coordinate.new(coordinate.x + 1, coordinate.y )
  end
  if coordinate.y < $cave.length - 2 && $cave[coordinate.y + 1][coordinate.x] == '.'
    yield Coordinate.new(coordinate.x, coordinate.y + 1 )
  end
  if coordinate.x > 0 && $cave[coordinate.y][coordinate.x - 1] == '.'
    yield Coordinate.new(coordinate.x - 1, coordinate.y )
  end
end

def adjacent_enemies(unit)
  enemy_species = unit.species == :elf ? :goblin : :elf
  enemies = []
  if unit.y > 0 && $cave[unit.y - 1][unit.x].is_a?(Integer)
    adjacent_unit = $units.find { |u| u.index == $cave[unit.y - 1][unit.x] }
    enemies << adjacent_unit if adjacent_unit.species == enemy_species
  end
  if unit.x < $cave[0].length - 2 && $cave[unit.y][unit.x + 1].is_a?(Integer)
    adjacent_unit = $units.find { |u| u.index == $cave[unit.y][unit.x + 1] }
    enemies << adjacent_unit if adjacent_unit.species == enemy_species
  end
  if unit.y < $cave.length - 2 && $cave[unit.y + 1][unit.x].is_a?(Integer)
    adjacent_unit = $units.find { |u| u.index == $cave[unit.y + 1][unit.x] }
    enemies << adjacent_unit if adjacent_unit.species == enemy_species
  end
  if unit.x > 0 && $cave[unit.y][unit.x - 1].is_a?(Integer)
    adjacent_unit = $units.find { |u| u.index == $cave[unit.y][unit.x - 1] }
    enemies << adjacent_unit if adjacent_unit.species == enemy_species
  end
  enemies
end


def choose_square(unit)
  closest_targets = targets(unit).each_with_object(Hash.new { |h, k| h[k] = [] }) do |target, distances|
    unoccupied_positions(target.coordinate) do |in_range|
      distance = shortest_distance(unit.coordinate, in_range)
      distances[distance] << in_range unless distance.nil?
    end
  end
  closest_targets[closest_targets.keys.min].sort do |a, b|
    a.y == b.y ? a.x <=> b.x : a.y <=> b.y
  end.first
end

def choose_step(unit, square)
  paths = []
  minimum_distance = 999_999
  unoccupied_positions(unit.coordinate) do |position|
    distance = shortest_distance(position, square)
    next if distance.nil?
    minimum_distance = [minimum_distance, distance].min
    paths << [position, distance]
  end

  paths
    .select { |p| p[1] == minimum_distance }
    .map { |p| p[0] }
    .sort { |a, b| a.y == b.y ? a.x <=> b.x : a.y <=> b.y }
    .first
end

$cave = []
$units = []
e = g = 1
File.open('day15-sample3.txt').readlines.each_with_index do |line, j|
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

square = choose_square($units.first)
pp $units.first
pp choose_step($units.first, square)

print_cave
3.times do
  order_units!
  $units.each do |unit|
    unless adjacent_enemies(unit).length > 0
      new_position = choose_step(unit, choose_square(unit))
      unless new_position.nil?
        $cave[unit.y][unit.x] = '.'
        unit.move_to(new_position)
        $cave[unit.y][unit.x] = unit.index
      end
    end
  end
  print_cave
end
