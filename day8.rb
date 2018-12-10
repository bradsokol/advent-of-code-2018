#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class Node
  attr_accessor :children, :children_count, :metadata, :metadata_count

  def initialize(children_count, metadata_count)
    @children = []
    @children_count = children_count
    @metadata = []
    @metadata_count = metadata_count
  end
end

def parse_node(data)
  node = Node.new(data.delete_at(0), data.delete_at(0))
  node.children_count.times do
    node.children << parse_node(data)
  end
  node.metadata_count.times { node.metadata << data.delete_at(0) }
  node
end

def sum_metadata(node)
  node.children.reduce(node.metadata.sum) { |sum, child| sum + sum_metadata(child) }
end

def node_value(node)
  if node.children.length == 0
    node.metadata.sum
  else
    node.metadata.reduce(0) do |sum, i|
      if i == 0 || i > node.children.length
        sum
      else
        sum + node_value(node.children[i - 1])
      end
    end
  end
end

input = File.open('day8.txt').readline.split(' ').map(&:to_i)
root = parse_node(input)

puts sum_metadata(root)
puts node_value(root)
