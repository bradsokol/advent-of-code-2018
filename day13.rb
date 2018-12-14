#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class Cart
  attr_reader :direction
  attr_accessor :x, :y

  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
    @turn_sequence = 0
  end

  def coordinates
    [x, y]
  end

  def move
    case direction
    when '^'
      @y -= 1
    when '>'
      @x += 1
    when 'v'
      @y += 1
    when '<'
      @x -= 1
    end
  end

  SLASH_DIRECTION = { '^' => '>', '>' => '^', 'v' => '<', '<' => 'v' }
  BACKSLASH_DIRECTION = { '^' => '<', '>' => 'v', 'v' => '>', '<' => '^' }
  LEFT_TURN = { '^' => '<', '>' => '^', 'v' => '>', '<' => 'v' }
  RIGHT_TURN = { '^' => '>', '>' => 'v', 'v' => '<', '<' => '^' }

  def adjust_direction(track_segment)
    @direction = case track_segment
    when '/'
      SLASH_DIRECTION[@direction]
    when '\\'
      BACKSLASH_DIRECTION[@direction]
    when '+'
      case @turn_sequence
      when 0
        LEFT_TURN[direction]
      when 1
        @direction
      when 2
        RIGHT_TURN[direction]
      end
    else
      @direction
    end
    if track_segment == '+'
      @turn_sequence = (@turn_sequence + 1) % 3
    end
  end
end

def find_carts(tracks)
  carts = []
  tracks.each_with_index do |row, j|
    row.each_with_index do |location, i|
      if '^>v<'.include?(location)
        carts << Cart.new(i, j, location)
        tracks[j][i] = 'v^'.include?(location) ? '|' : '-'
      end
    end
  end
  carts
end

def sort_carts!(carts)
  carts.sort! { |a, b| a.y == b.y ? a.x <=> b.x : a.y <=> b.y }
end

def collision?(carts)
  carts.map(&:coordinates).uniq.length < carts.length
end

def collision_location(carts)
  coordinates = carts.map(&:coordinates)
  coordinates.detect { |cart| coordinates.count(cart) > 1 }
end

def print_tracks(tracks, carts)
  tracks.each_with_index do |row, y|
    row.each_with_index do |column, x|
      cart = carts.find { |c| c.coordinates == [x, y] }
      printf cart ? cart.direction : tracks[y][x]
    end
  end
  puts "\n"
  puts '*' * 25
end

tracks = File.open('day13.txt').readlines.map { |line| line.chars }
GRID_SIZE = tracks[0].length

carts = find_carts(tracks)
until carts.length == 1
  # print_tracks(tracks, carts)
  sort_carts!(carts)

  carts.each do |cart|
    next if cart.coordinates == [GRID_SIZE, GRID_SIZE]
    cart.move
    abort "Bad x #{cart.x}" if cart.x < 0 || cart.x >= GRID_SIZE
    abort "Bad y #{cart.y}" if cart.y < 0 || cart.y >= GRID_SIZE
    abort "Off tracks at (#{cart.x}, #{cart.y})" if tracks[cart.y][cart.x].empty?
    cart.adjust_direction(tracks[cart.y][cart.x])
    if collision?(carts)
      collision_location = collision_location(carts)
      pp collision_location if carts.length == 17 && collision_location != [GRID_SIZE, GRID_SIZE]
      collided_carts = carts.select { |c| c.coordinates == collision_location }
      abort 'Should be two' if collided_carts.length != 2
      collided_carts.each { |c| c.x = c.y = GRID_SIZE }
    end
  end

  carts.delete_if { |cart| cart.coordinates == [GRID_SIZE, GRID_SIZE] }
end

pp carts[0].coordinates
