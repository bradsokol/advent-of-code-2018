#! /usr/bin/env ruby

require 'pry'
require 'digest'
require 'set'

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
$history = Set.new

first_repeat = nil
1_000_000_000.times do |i|
  break if i == 468
  $previous = $forest.map { |row| row.dup } 
  digest = Digest::MD5.hexdigest($previous.map(&:join).join)
  if first_repeat.nil?
    if $history.include?(digest)
      p i
      first_repeat = digest
    end
  elsif digest == first_repeat
    p i
    break
  end
  $history << digest

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
