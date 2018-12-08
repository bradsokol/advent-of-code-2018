#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

class Step
  attr_reader :name, :after, :before

  def initialize(name)
    @name = name
    @before = []
    @after = []
    @complete = false
  end

  def add_before(before_step)
    if @before.none? { |step| step.name == before_step.name }
      @before << before_step
    end
  end

  def add_after(after_step)
    if @after.none? { |step| step.name == after_step.name }
      @after << after_step
      @after.sort! { |a, b| a.name <=> b.name }
    end
  end

  def complete!
    @complete = true
  end

  def incomplete!
    @complete = false
  end

  def complete?
    @complete
  end

  def ready?
    @before.empty? || @before.all?(&:complete?)
  end

  def incomplete_after_steps
    after.select(&:ready?)
  end

  def time_to_complete
    name.codepoints.first - 64 + 60
  end
end

class Task
  attr_reader :step

  def initialize(step)
    @step = step
    @time_remaining = step.time_to_complete
  end

  def tick!
    @time_remaining -= 1
    @step.complete! if @time_remaining == 0
  end

  def complete?
    @step.complete?
  end
end

def workable_steps(steps, queue, count)
  queue.chars.map do |name|
    steps[name].ready? ? steps[name] : nil
  end.compact.take(count)
end

steps = File.open('day7.txt').readlines.each_with_object({}) do |line, h|
  before, after = line.match(/Step (.) must be finished before step (.) can begin\./).captures
  unless h.key?(before)
    h[before] = Step.new(before)
  end
  unless h.key?(after)
    h[after] = Step.new(after)
  end

  h[before].add_after(h[after])
  h[after].add_before(h[before])
end

step = steps.values.select(&:ready?).first
work_done = step.name
step.complete!

queue = step.incomplete_after_steps.map(&:name).sort
until work_done.length == steps.length do
  step = steps[queue.delete_at(0)]
  unless step.complete?
    work_done += step.name
    step.complete!
    queue += step.incomplete_after_steps.map(&:name)
  end
  queue.delete(step.name)
  queue.sort!
end
puts work_done

steps.values.each(&:incomplete!)
workers = Array.new(5)

t = 0
until steps.values.all?(&:complete?) do
  (0...workers.length).each do |i|
    next if workers[i].nil?
    workers[i].tick!
    workers[i] = nil if workers[i].complete?
  end

  free_workers = workers.count(&:nil?)
  next_steps = workable_steps(steps, work_done, free_workers)
  next_steps.each do |next_step|
    workers[workers.index(nil)] = Task.new(next_step)
    work_done.delete!(next_step.name)
  end

  # puts "#{t} #{workers[0]&.step&.name} #{workers[1]&.step&.name}"
  t += 1
end
puts t - 1
