#! /usr/bin/env ruby

require 'pry'
require 'set'

$data = File.open('day20.txt').readline
$data = '^WNE$'
$data = '^ENWWW(NEEE|SSE(EE|N))$'
$data = '^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$'

$directions = {
  'N' =>  Complex(0, 1),
  'S' =>  Complex(0, -1),
  'E' =>  1,
  'W' =>  -1,
}
$map = { 0 => 0 }

def traverse(enum, pos=0, depth=0)
  initial_pos = pos
  initial_depth = depth

  enum.each do |char|
    if $directions.key?(char)
      pos += $directions[char]
      if $map.key?(pos)
        depth = $map[pos]
      else
        depth += 1
        $map[pos] = depth
      end
    elsif char == '|'
      pos = initial_pos
      depth = initial_depth
    elsif char == '('
      traverse(enum, pos, depth)
    elsif char == ')'
      return
    elsif char == '$'
      return
    end
  end
end

traverse($data.chars[1..-1].each)
puts $map.values.max
puts $map.values
  .select { |v| v >= 1000 }
  .sum
