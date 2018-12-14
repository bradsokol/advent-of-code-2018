#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class Recipe
  attr_reader :index, :score
  attr_accessor :next, :previous

  def initialize(score, index)
    @index = index
    @score = score
    @next = nil
    @previous = nil
  end
end

def next_recipe(head, current, steps)
  steps.times do
    unless current.next.nil?
      current = current.next
    else
      current = head
    end
  end
  current
end

input = '260321'

head = Recipe.new(3, 0)
tail = Recipe.new(7, 1)
head.next = tail
tail.previous = head
elf1_recipe = head
elf2_recipe = tail
last_recipes = ''

while last_recipes.index(input).nil?
  score1 = elf1_recipe.score
  score2 = elf2_recipe.score
  sum = score1 + score2
  if sum > 9
    tail.next = Recipe.new(sum / 10, tail.index + 1)
    tail.next.next = Recipe.new(sum % 10, tail.index + 2)
    tail.next.previous = tail
    tail.next.next.previous = tail.next
    tail = tail.next.next
    last_recipes += tail.previous.score.to_s
  else
    tail.next = Recipe.new(sum, tail.index + 1)
    tail.next.previous = tail
    tail = tail.next
  end
  last_recipes += tail.score.to_s
  last_recipes = last_recipes[-(input.length + 1)..-1] if last_recipes.length > input.length

  elf1_recipe = next_recipe(head, elf1_recipe, score1 + 1)
  elf2_recipe = next_recipe(head, elf2_recipe, score2 + 1)
end

pos = tail.previous.previous.previous.previous.previous.previous
until pos.nil?
  puts "#{pos.score}, #{pos.index}"
  pos = pos.next
end
