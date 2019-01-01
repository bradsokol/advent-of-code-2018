#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'
require 'set'

$registers = Array.new(6, 0)

$instructions = {
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

input = File.open('day21.txt')
$ip_register = input.readline.match(/^\#ip (\d+)$/).captures[0].to_i

$program = input.readlines.map do |line|
  mnemonic = line.match(/^([a-z]{4}) /).captures[0]
  a, b, c = line.match(/[a-z]{4} (\d+) (\d+) (\d+)[^\d]*/).captures.map(&:to_i)
  [mnemonic, a, b, c]
end

def run(r0)
  $registers = Array.new(6, 0)
  $registers[0] = r0
  count = 0
  ip = 0
  result = loop do
    # 6.times { |i| printf "%8d ", $registers[i] }
    # puts ''
    p $registers[4] if ip == 28

    $registers[$ip_register] = ip

    mnemonic, a, b, c = $program[ip]
    $instructions[mnemonic].call(a, b, c)
    count += 1
    return nil if count == 10_000_000

    ip = $registers[$ip_register]

    ip += 1

    break count if ip < 0 || ip >= $program.length
  end
  result
end

1.times do |i|
  result = run(256)
  unless result.nil?
    p "i: #{i} result: #{result}"
  end
end
