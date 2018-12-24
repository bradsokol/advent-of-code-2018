#! /usr/bin/env ruby

require 'pry'
require 'set'

class Room
  attr_accessor :north, :east, :south, :west, :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @north = @east = @south = @west = '?'
  end

  def visualize
    puts "\##{@north == '?' ? '?' : '-'}\#"
    puts "#{@west == '?' ? '?' : '|'}.#{@east == '?' ? '?' : '|'}"
    puts "\##{@south == '?' ? '?' : '-'}\#"
  end

  def adjacent
    [north, east, west, south].delete_if { |r| r == '?' }
  end
end

def add_room(x, y, from_room, direction)
  room = $rooms[y][x]
  unless room
    room = $rooms[y][x] = Room.new(x, y)
  end

  case direction
  when 'N'
    from_room.north = room
    room.south = from_room
  when 'E'
    from_room.east = room
    room.west = from_room
  when 'S'
    from_room.south = room
    room.north = from_room
  when 'W'
    from_room.west = room
    room.east = from_room
  end

  room
end

$rooms = Hash.new{ |hash, key| hash[key] = Hash.new }
current_room = Room.new(0, 0)
my_location = current_room
x = y = 0
$rooms[y][x] = current_room
branches = []

regex = File.open('day20.txt').readline
# regex = '^WNE$'
# regex = '^ENWWW(NEEE|SSE(EE|N))$'
# regex = '^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$'
regex.chars.each do |char|
  next if char == '^'
  break if char == '$'

  case char
  when 'N'
    y += 1
    current_room = add_room(x, y, current_room, char)
  when 'E'
    x += 1
    current_room = add_room(x, y, current_room, char)
  when 'S'
    y -= 1
    current_room = add_room(x, y, current_room, char)
  when 'W'
    x -= 1
    current_room = add_room(x, y, current_room, char)
  when '('
    branches.push(current_room)
  when ')'
    current_room = branches.pop
    x = current_room.x
    y = current_room.y
  when '|'
    current_room = branches.last
    x = current_room.x
    y = current_room.y
  end
end

def find_path(current_room, distance)
  next_rooms = current_room.adjacent.delete_if { |r| $visited.include?(r) }
  $visited.merge(next_rooms)
  $longest_path = [$longest_path, distance].max
  next_rooms.each { |r| find_path(r, distance + 1) }
end

current_room = my_location
$longest_path = 0
$visited = Set.new
find_path(current_room, 0)

p $longest_path
