#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

def iterate(recipes, elf1, elf2)
  score1 = recipes[elf1]
  score2 = recipes[elf2]
  sum = score1 + score2
  if sum > 9
    recipes += [sum / 10, sum % 10]
  else
    recipes << sum
  end
  [recipes, (elf1 + score1 + 1) % recipes.length, (elf2 + score2 + 1) % recipes.length]
end

input = 260_321
recipes = [3, 7]
elf1 = 0
elf2 = 1

until recipes.length >= input + 10
  recipes, elf1, elf2 = iterate(recipes, elf1, elf2)
end

pp recipes[input...(input + 10)].join
