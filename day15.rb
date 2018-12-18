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
  attr_reader :hit_points, :strength, :index, :species, :coordinate, :attack_power, :hit_points

  def initialize(species, index, x, y)
    @species = species
    @index = index
    @coordinate = Coordinate.new(x, y)
    @attack_power = 3
    @hit_points = 200
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

  def strike
    @hit_points -= 3
  end

  def dead?
    @hit_points <= 0
  end
end

def print_cave(i)
  printf "\nAfter Round #{i}\n"
  $cave.each do |row|
    status = []
    row.each do |position|
      if position == '.' || position == '#'
        printf position
      elsif position == "\n"
        # Do nothing
      elsif position > 0
        printf 'E'
        status << "E(#{$units.find { |u| u.index == position}.hit_points})"
      else
        printf 'G'
        status << "G(#{$units.find { |u| u.index == position}.hit_points})"
      end
    end
    printf "  %s\n", status.join(' ')
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
  puts $shortest_distances.length
  return 0 if coordinate == target

  key = [coordinate, target]
  return $shortest_distances[key] if $shortest_distances.key?(key)

  queue = Queue.new
  unoccupied_positions(coordinate) { |position| queue.push([position, 1]) }
  visited = Set.new
  until queue.empty? do
    position, distance = queue.pop
    return distance if target == position
    visited << position

    unoccupied_positions(position) do |p|
      unless visited.include?(p)
        queue.push([p, distance + 1])
        $shortest_distances[[coordinate, p]] = distance + 1
      end
    end
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

i = 0
print_cave(i)
early = false
loop do
  order_units!
  $units.each do |unit|
    next if unit.dead?
    puts unit.index
    $shortest_distances = {}

    unless adjacent_enemies(unit).length > 0
      new_position = choose_step(unit, choose_square(unit))
      unless new_position.nil?
        $cave[unit.y][unit.x] = '.'
        unit.move_to(new_position)
        $cave[unit.y][unit.x] = unit.index
      end
    end

    enemies = adjacent_enemies(unit)
    if enemies.length > 0
      lowest_hp = enemies.map(&:hit_points).min
      victim = enemies
        .select { |enemy| enemy.hit_points == lowest_hp }
        .sort { |a, b| a.y == b.y ? a.x <=> b.x : a.y <=> b.y }
        .first

      victim.strike
      if victim.dead?
        $cave[victim.coordinate.y][victim.coordinate.x] = '.'
      end
    end
    if $units.select { |u| u.species == :elf }.all? { |u| u.dead? } ||
      $units.select { |u| u.species == :goblin }.all? { |u| u.dead? }
      early = true unless unit.index == $units[-1].index
      break
    end
  end
  $units.delete_if { |unit| unit.dead? }
  i += 1 unless early
  print_cave(i)
  break if $units.all? { |u| u.species == :elf } || $units.all? { |u| u.species == :goblin }
  printf "E:#{$units.sum { |u| u.species == :elf ? u.hit_points : 0 }} G:#{$units.sum { |u| u.species == :goblin ? u.hit_points : 0 }}\n"
end
pp $units.sum(&:hit_points) * i
