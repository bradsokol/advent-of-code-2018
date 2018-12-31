#! /usr/bin/env ruby

require 'pry'

def print_ground(x = nil, y = nil, io = $stdout)
  $ground.each_with_index do |row, j|
    chars = row.join
    chars[x] = '*' if j == y
    io.puts chars
  end
  io.puts ''
end

def print_around(x, y, range=10)
  $ground[y-range..y+range].each_with_index do |row, i|
    line = row[x - range..x + range].join
    line[range] = '*' if i == range
    puts line
  end
  puts ''
end

def make_bar(x, y, delta)
  $ground[y][x] = '|'
  until $ground[y][x] == '.' || $ground[y][x] == '#'
    $ground[y][x] = '|'
    x += delta
  end
end

def move(x, y, direction)
  delta = direction == :left ? -1 : 1
  wall = false
  loop do
    $ground[y][x] = '~'
    if $ground[y][x + delta] == '.' || $ground[y][x + delta] == '|'
      if $ground[y + 1][x + delta] == '.'
        make_bar(x + delta, y, -1 * delta)
        falling_water(x + delta, y)
        break
      else
        x += delta
      end
    elsif $ground[y][x + delta] == '#'
      wall = true
      break
    elsif $ground[y][x + delta] == '~'
      break
    else
      binding.pry
      raise "Unexpected char #{$ground[y][x + delta]} at [#{x + delta}, #{y}]"
    end
  end
  wall
end

def end_is_wall?(row, x)
  return false if row[x+1] == '~'
  until row[x] == '#' || row[x] == '.'
    x += 1
  end
  row[x] == '#'
end

$count = 0
def falling_water(start_x, start_y)
  return if '~|'.include?($ground[start_y][start_x - 1]) &&'~|'.include?($ground[start_y][start_x + 1])
  $count += 1
  # puts "#{$count}:"
  # print_ground(start_x, start_y)
  # binding.pry if start_x == 166 && start_y == 513
  # binding.pry if $count == 11

  position = [start_x, start_y]

  # Fall down
  until position[1] == $ground.size - 1 || '~#|'.include?($ground[position[1] + 1][position[0]])
    position[1] += 1
    return if '~|'.include?($ground[position[1]][position[0]])
    $ground[position[1]][position[0]] = '|'
  end
  return if position[1] == $ground.size - 1
  return if $ground[position[1] + 1][position[0]] == '|'
  stopped_falling = position.dup

  left_wall = move(*position, :left)

  right_wall = move(*stopped_falling, :right)

  x, y = stopped_falling

  if left_wall && !right_wall
    while $ground[y][x] == '~'
      $ground[y][x] = '|'
      x -= 1
    end
  elsif !left_wall && right_wall
    while $ground[y][x] == '~'
      $ground[y][x] = '|'
      x += 1
    end
  elsif left_wall && right_wall
    until $ground[y][x] == '#'
      $ground[y][x] = '~'
      x -= 1
    end
    x, y = stopped_falling
    until $ground[y][x] == '#'
      $ground[y][x] = '~'
      x += 1
    end
    x, y = stopped_falling
    falling_water(x, y - 1)
  end

  x, y = stopped_falling
  left_wall = end_is_wall?($ground[y].reverse, x)
  right_wall = end_is_wall?($ground[y], x)
  falling_water(x, y - 1) if left_wall && right_wall
  # break if y == $ground.size - 1
end

def correct
  count = 0
  $ground.each_with_index do |row, y|
    # binding.pry if y == 98
    chars = row.join
    while chars.match(/.*[#][|]+[~]+[#].*/)
      pattern = chars.match(/.*([#][|]+[~]+[#]).*/).captures.first
      chars.sub!(pattern, pattern.tr('|', '~'))
    end
    while chars.match(/.*[#][~]+[|]+[#].*/)
      pattern = chars.match(/.*([#][~]+[|]+[#]).*/).captures.first
      chars.sub!(pattern, pattern.tr('|', '~'))
    end
    count += chars.count('~')
    p chars
  end
  p count
end

# x: 314..594  y: 3..1801
$ground = Array.new(1802)
(0..1802).each { |y| $ground[y] = Array.new(283, '.') }
x_offset = 313
min_y = 3
max_y = 1801
file = File.open('day17.txt')

# x: 495..506  y: 1..13
# $ground = Array.new(14)
# (0..14).each { |y| $ground[y] = Array.new(14, '.') }
# x_offset = 494
# min_y = 1
# max_y = 13
# file = File.open('day17-sample.txt')

file.readlines.each do |line|
  dimension1, a, b, c = line.match(/([xy])=(\d+), [xy]=(\d+)\.\.(\d+)/).captures
  if dimension1 == 'x'
    (b.to_i..c.to_i).each { |y| $ground[y][a.to_i - x_offset] = '#' }
  else
    (b.to_i..c.to_i).each { |x| $ground[a.to_i][x - x_offset] = '#' }
  end
end

falling_water(500 - x_offset, 0)

# print_ground
p $ground[min_y..max_y].reduce(0) { |sum, row| sum += row.count { |c| c == '~' || c == '|' } }
correct
