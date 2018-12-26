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

regex = File.open('day20.txt').readline
# regex = '^WNE$'
# regex = '^ENWWW(NEEE|SSE(EE|N))$'
# regex = '^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$'
# regex = '^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$'
i = 1
forks = []
continuations = []
dollars = 0
loop do
  char = regex[i]
  if char == '$'
    dollars += 1
    puts "#{dollars} #{continuations.length}"

    break if continuations.empty?
    current_room, i, forks = continuations.pop
    x = 1
    until x == 0
      x -= 1 if regex[i] == ')'
      x += 1 if regex[i] == '('
      i += 1
    end
    char = regex[i]
  end

  case char
  when '$'
    next
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
    forks.push(current_room)
  when ')'
    forks.pop
    continuations.pop if regex[i - 1] == '|'
  when '|'
    continuations.push([current_room, i, forks.clone])
    current_room = forks.last
    x = current_room.x
    y = current_room.y
  end
  i += 1
end

def find_path(current_room, distance)
  next_rooms = current_room.adjacent.delete_if { |r| $visited.include?(r) }
  $visited.merge(next_rooms)
  $longest_path = [$longest_path, distance].max
  $one_thousand += 1 if distance == 1000
  $one_thousand += next_rooms.length if distance > 1000
  next_rooms.each { |r| find_path(r, distance + 1) }
end

$longest_path = 0
$one_thousand = 0
$visited = Set.new
find_path(my_location, 0)

p $longest_path
p $one_thousand
