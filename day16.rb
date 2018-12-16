#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

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

774.times do |n|
  before = input.readline.match(/Before: \[(\d+), (\d+), (\d+), (\d+)\]/).captures.map(&:to_i)
  op_code = input.readline.match(/^(\d+) (\d+) (\d+) (\d+)/).captures.map(&:to_i)
  after = input.readline.match(/After:  \[(\d+), (\d+), (\d+), (\d+)\]/).captures.map(&:to_i)
  input.readline

  count = 0
  16.times do |i|
    $registers = before.clone
    $ops[i].call(op_code[1], op_code[2], op_code[3])
    count += 1 if $registers == after
  end
  $counts[count] += 1
end

puts $counts[3..-1].sum
