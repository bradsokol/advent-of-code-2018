#! /usr/bin/env ruby

require 'pry'

def count_adjacent(x, y, char)
  count = 0
  if y > 0
    count += 1 if x > 0 && $previous[y - 1][x - 1] == char
    count += 1 if $previous[y - 1][x] == char
    count += 1 if x < 49 && $previous[y - 1][x + 1] == char
  end
  count += 1 if x > 0 && $previous[y][x - 1] == char
  count += 1 if x < 49 && $previous[y][x + 1] == char
  if y < 49
    count += 1 if x > 0 && $previous[y + 1][x - 1] == char
    count += 1 if $previous[y + 1][x] == char
    count += 1 if x < 49 && $previous[y + 1][x + 1] == char
  end
  count
end

$forest = File.open('day18.txt').readlines.map(&:strip).map(&:chars)

10.times do
  $previous = $forest.map { |row| row.dup } 

  $previous.each_with_index do |row, y|
    row.each_with_index do |char, x|
      case char
      when '.'
        if count_adjacent(x, y, '|') >= 3
          $forest[y][x] = '|'
        end
      when '|'
        if count_adjacent(x, y, '#') >= 3
          $forest[y][x] = '#'
        end
      when '#'
        lumberyards = count_adjacent(x, y, '#')
        trees = count_adjacent(x, y, '|')
        unless lumberyards >= 1 && trees >= 1
          $forest[y][x] = '.'
        end
      else
        raise "Unexpected char #{char}"
      end
    end
  end
end

wooded = $forest.reduce(0) { |sum, row| sum += row.count { |c| c == '|' } }
lumberyards = $forest.reduce(0) { |sum, row| sum += row.count { |c| c == '#' } }
p wooded * lumberyards
