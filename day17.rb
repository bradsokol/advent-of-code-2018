#! /usr/bin/env ruby

require 'pry'

def print_ground
  $ground.each { |row| puts row.join }
  puts ''
end

def print_around(x, y, range=10)
  $ground[y-range..y+range].each_with_index do |row, i|
    line = row[x - range..x + range].join
    line[range] = '*' if i == range
    puts line
  end
  puts ''
end

def move(x, y, direction)
  start_x = x
  delta = direction == :left ? -1 : 1
  wall = false
  loop do
    $ground[y][x] = '~'
    if $ground[y][x + delta] == '.' || $ground[y][x + delta] == '|'
      if $ground[y + 1][x + delta] == '.'
        if direction == :left
          $ground[y][(x - 1)..start_x] = ('|' * (start_x - (x - 1) + 1)).chars
        else
          $ground[y][start_x..(x + 1)] = ('|' * ((x + 1) - start_x + 1)).chars
        end
        $waterfalls.push([x + delta, y])
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

def falling_water
  loop do
    # print_ground

    position = $waterfalls.shift
    break if position.nil?
    start_x, start_y = position

    # Fall down
    until position[1] == $ground.size - 1 || '~#'.include?($ground[position[1] + 1][position[0]])
      position[1] += 1
      $ground[position[1]][position[0]] = '|'
    end
    next if position[1] == $ground.size - 1
    stopped_falling = position.dup

    left_wall = move(*position, :left)

    right_wall = move(*stopped_falling, :right)

    x, y = stopped_falling
    # while '~|'.include?($ground[y][x])
    #   x -= 1
    # end
    # left_wall = $ground[y][x] == '#'
    # x, y = stopped_falling
    # c = $ground[y][x]
    # while '~|'.include?(c)
    #   x += 1
    #   c = $ground[y][x]
    # end
    # right_wall = $ground[y][x] == '#'

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
      $waterfalls.insert(0, [x, y - 1])
    end

    if $waterfalls.empty?
     break if y == $ground.size - 1

     binding.pry
     $waterfalls << [start_x, start_y - 1]
    end
  end
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

$waterfalls = [[500 - x_offset, 0]]
falling_water

print_ground
sum = 0
$ground[min_y..max_y].each { |row| sum += row.count { |c| c == '~' || c == '|' } }
p sum
