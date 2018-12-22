#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'
require 'set'

$registers = Array.new(6, 0)

instructions = {
  'addi' => lambda { |a, b, c| $registers[c] = $registers[a] + b },
  'addr' => lambda { |a, b, c| $registers[c] = $registers[a] + $registers[b] },

  'bani' => lambda { |a, b, c| $registers[c] = $registers[a] & b },
  'banr' => lambda { |a, b, c| $registers[c] = $registers[a] & $registers[b] },

  'bori' => lambda { |a, b, c| $registers[c] = $registers[a] | b },
  'borr' => lambda { |a, b, c| $registers[c] = $registers[a] | $registers[b] },

  'eqir' => lambda { |a, b, c| $registers[c] = a == $registers[b] ? 1 : 0 },
  'eqri' => lambda { |a, b, c| $registers[c] = $registers[a] == b ? 1 : 0 },
  'eqrr' => lambda { |a, b, c| $registers[c] = $registers[a] == $registers[b] ? 1 : 0 },

  'gtir' => lambda { |a, b, c| $registers[c] = a > $registers[b] ? 1 : 0 },
  'gtri' => lambda { |a, b, c| $registers[c] = $registers[a] > b ? 1 : 0 },
  'gtrr' => lambda { |a, b, c| $registers[c] = $registers[a] > $registers[b] ? 1 : 0 },

  'mulr' => lambda { |a, b, c| $registers[c] = $registers[a] * $registers[b] },
  'muli' => lambda { |a, b, c| $registers[c] = $registers[a] * b },

  'setr' => lambda { |a, _, c| $registers[c] = $registers[a] },
  'seti' => lambda { |a, _, c| $registers[c] = a },
}

input = File.open('day19.txt')
ip_register = input.readline.match(/^\#ip (\d+)$/).captures[0].to_i
ip = 0

program = input.readlines.map do |line|
  mnemonic = line.match(/^([a-z]{4}) /).captures[0]
  a, b, c = line.match(/[a-z]{4} (\d+) (\d+) (\d+)[^\d]*/).captures.map(&:to_i)
  [mnemonic, a, b, c]
end

# $registers[0] = 1
last0 = $registers[0]
loop do
  $registers[ip_register] = ip

  mnemonic, a, b, c = program[ip]
  instructions[mnemonic].call(a, b, c)

  ip = $registers[ip_register]

  ip += 1

  break if ip < 0 || ip >= program.length
  if $registers[0] != last0
    pp $registers[0]
    last0 = $registers[0]
  end
end

pp $registers[0]
