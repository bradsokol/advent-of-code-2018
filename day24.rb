#! /usr/bin/env ruby

require 'pry'

class Group
  attr_reader :damage, :damage_type, :initiative, :type, :weaknesses, :immunities, :index
  attr_accessor :hit_points, :units

  def initialize(type, index, units, hit_points, damage, damage_type, initiative, weaknesses = [], immunities = [])
    @type = type
    @index = index
    @units = units
    @hit_points = hit_points
    @damage = damage
    @damage_type = damage_type
    @initiative = initiative
    @weaknesses = weaknesses
    @immunities = immunities
  end

  def effective_power
    @units * @damage
  end

  def attack(other)
    abort 'Attacking self' if type == other.type
    damage = potential_damage_inflicted_on(other)
    other_capacity = other.units * other.hit_points
    units_killed = damage > other_capacity ? other.units : damage / other.hit_points
    # puts "#{type == :infection ? "Infection" : "Immune System"} group #{index} attacks defending group #{other.index}, killing #{other.units} units"
    other.units -= units_killed
  end

  def potential_damage_inflicted_on(other)
    factor = if other.immunities.include?(damage_type)
               0
             elsif other.weaknesses.include?(damage_type)
               2
             else
               1
             end
    effective_power * factor
  end
end

def parse_group(type, index, input)
  units, hit_points, parens, damage, damage_type, initiative = input.match(
    /^(\d+) units each with (\d+) hit points (\(.+\))?\s?with an attack that does (\d+) ([a-z]+) damage at initiative (\d+)$/
  ).captures
  immunities, weaknesses = if parens.nil?
    [[], []]
  else
    x = parens[1..-2].split('; ').sort
    if x.length == 1
      if x[0].start_with?('weak to ')
        [[], x[0][8..-1].split(', ').map(&:to_sym)]
      else
        [x[0][10..-1].split(', ').map(&:to_sym), []]
      end
    else
      [x[0][10..-1].split(', ').map(&:to_sym), x[1][8..-1].split(', ').map(&:to_sym)]
    end
  end

  Group.new(type, index, units.to_i, hit_points.to_i, damage.to_i, damage_type.to_sym, initiative.to_i, weaknesses, immunities)
end

def sort_for_target_selection(groups)
  groups.sort do |a, b|
    b.effective_power == a.effective_power ? b.initiative <=> a.initiative : b.effective_power <=> a.effective_power
  end
end

def select_targets(group, enemies)
  candidate_targets = enemies.sort do |a, b|
    damage_a = group.potential_damage_inflicted_on(a)
    damage_b = group.potential_damage_inflicted_on(b)
    damage_a == damage_b ?
      (a.effective_power == b.effective_power ? b.initiative <=> a.initiative : b.effective_power <=> a.effective_power) :
      damage_b <=> damage_a
  end

  candidate_targets.each do |t|
    # puts "#{group.type} group #{group.index} would deal defending group #{t.index} #{group.potential_damage_inflicted_on(t)} damage"
  end
  candidate_targets.delete_if { |t| group.potential_damage_inflicted_on(t) == 0 }
  # candidate_target = candidate_targets.first
  # group.potential_damage_inflicted_on(candidate_target) > 0 ? candidate_target : nil
end

def print_groups(groups)
  puts "Immune System:"
  groups
    .select { |g| g.type == :immune_system }
    .sort { |a, b| a.index <=> b.index }
    .each { |g| puts "Group #{g.index} contains #{g.units} units" }
  puts "Infections:"
  groups
    .select { |g| g.type == :infection }
    .sort { |a, b| a.index <=> b.index }
    .each { |g| puts "Group #{g.index} contains #{g.units} units" }
  puts ''
end

file = File.open('day24.txt')
file.readline
groups = []
i = 1
loop do
  line = file.readline.strip
  break if line.empty?
  groups << parse_group(:immune_system, i, line)
  i += 1
end
file.readline

i = 1
file.readlines.each do |line|
  groups << parse_group(:infection, i, line)
  i += 1
end

until groups.map(&:type).uniq.count == 1
  # print_groups(groups)

  targets = {}
  sort_for_target_selection(groups).each do |group|
    selected_targets = select_targets(group, groups.select { |g| g.type != group.type })
    while !selected_targets.empty? && targets.values.include?(selected_targets.first) do
      selected_targets.delete_at(0)
    end
    unless selected_targets.empty?
      targets[group] = selected_targets.first
    end
  end
  # puts ''

  attacking_groups = targets.keys.sort { |a, b| b.initiative <=> a.initiative }
  attacking_groups.each do |attacking_group|
    next unless attacking_group.units > 0
    target = targets[attacking_group]
    attacking_group.attack(target)
  end
  # binding.pry

  groups.delete_if { |group| group.units < 1 }
  # puts ''
end

p groups.map(&:units).sum
