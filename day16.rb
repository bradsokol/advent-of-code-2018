#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'
require 'set'

def print_matches
  puts ''
  printf '   '
  16.times { |i| printf(" %02i ", i) }
  puts ''
  puts '-' * 70
  $matches.each_with_index do |x, i|
    printf("%02i|", i)
    x.each do |y|
      printf("%3i ", y)
    end
    puts ''
  end
end

$registers = Array.new(4, 0)
$counts = Array.new(16, 0)

addi = lambda { |a, b, c| $registers[c] = $registers[a] + b }
addr = lambda { |a, b, c| $registers[c] = $registers[a] + $registers[b] }

bani = lambda { |a, b, c| $registers[c] = $registers[a] & b }
banr = lambda { |a, b, c| $registers[c] = $registers[a] & $registers[b] }

bori = lambda { |a, b, c| $registers[c] = $registers[a] | b }
borr = lambda { |a, b, c| $registers[c] = $registers[a] | $registers[b] }

eqir = lambda { |a, b, c| $registers[c] = a == $registers[b] ? 1 : 0 }
eqri = lambda { |a, b, c| $registers[c] = $registers[a] == b ? 1 : 0 }
eqrr = lambda { |a, b, c| $registers[c] = $registers[a] == $registers[b] ? 1 : 0 }

gtir = lambda { |a, b, c| $registers[c] = a > $registers[b] ? 1 : 0 }
gtri = lambda { |a, b, c| $registers[c] = $registers[a] > b ? 1 : 0 }
gtrr = lambda { |a, b, c| $registers[c] = $registers[a] > $registers[b] ? 1 : 0 }

mulr = lambda { |a, b, c| $registers[c] = $registers[a] * $registers[b] }
muli = lambda { |a, b, c| $registers[c] = $registers[a] * b }

setr = lambda { |a, _, c| $registers[c] = $registers[a] }
seti = lambda { |a, _, c| $registers[c] = a }

$ops=[addi, addr, bani, banr, bori, borr, eqir, eqri, eqrr, gtir, gtri, gtrr, muli, mulr, seti, setr]
input = File.open('day16.txt')

$matches = []
16.times { |i| $matches[i] = Array.new(16, 0) }
774.times do |n|
  before = input.readline.match(/Before: \[(\d+), (\d+), (\d+), (\d+)\]/).captures.map(&:to_i)
  op_code = input.readline.match(/^(\d+) (\d+) (\d+) (\d+)/).captures.map(&:to_i)
  after = input.readline.match(/After:  \[(\d+), (\d+), (\d+), (\d+)\]/).captures.map(&:to_i)
  input.readline

  count = 0
  16.times do |mnemonic|
    $registers = before.clone
    $ops[mnemonic].call(op_code[1], op_code[2], op_code[3])
    if $registers == after
      count += 1
      $matches[mnemonic][op_code[0]] += 1
    end
  end
  $counts[count] += 1
end

puts $counts[3..-1].sum

$ops_map = Hash.new(-1)
until $ops_map.length == 16
  one = $matches.find { |r| r.count(0) == 15 }
  mnemonic = $matches.index(one)
  op_code = one.index { |o| o != 0 }
  $ops_map[op_code] = mnemonic

  $matches.each { |r| r[op_code] = 0 }
end

$registers = Array.new(4, 0)

input.readline
input.readline
input.readlines.each do |line|
  op_code, a, b, c = line.match(/^(\d+) (\d+) (\d+) (\d+)/).captures.map(&:to_i)
  $ops[$ops_map[op_code]].call(a, b, c)
end
puts $registers[0]
