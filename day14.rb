#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

def iterate(recipes, elf1, elf2)
  score1 = recipes[elf1].to_i
  score2 = recipes[elf2].to_i
  sum = score1 + score2
  if sum > 9
    recipes += "#{sum / 10}#{sum % 10}"
  else
    recipes += "#{sum}"
  end
  [recipes, (elf1 + score1 + 1) % recipes.length, (elf2 + score2 + 1) % recipes.length]
end

input = '260321'
recipes = '37'
elf1 = 0
elf2 = 1

while recipes.index(input).nil?
  score1 = recipes[elf1].to_i
  score2 = recipes[elf2].to_i
  sum = score1 + score2
  if sum > 9
    recipes += "#{sum / 10}#{sum % 10}"
  else
    recipes += "#{sum}"
  end
  elf1 = (elf1 + score1 + 1) % recipes.length
  elf2 = (elf2 + score2 + 1) % recipes.length
end

pp recipes.index(input)
