#! /usr/bin/env ruby

# frozen_string_literal: true

require 'pp'
require 'pry'

GuardRecord = Struct.new(:guard_id, :record)

observations = File.open('day4.txt').readlines.each_with_object({}) do |observation, memo|
  year, month, day, hour, minute, event = observation.match(/\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\] (.+)$/).captures
  time = Time.new(year, month, day, hour, minute)
  memo[time] = event
end

records = observations.keys.sort.each_with_object({}) do |timestamp, memo|
  event = observations[timestamp]
  if event.start_with?('Guard')
    guard_id = event.match(/Guard #(\d+) begins shift/).captures[0].to_i
    timestamp += 3600 if timestamp.hour == 23
    key = "%02i-%02i" % [timestamp.month, timestamp.day]
    memo[key] = GuardRecord.new(guard_id, '.' * 60)
  elsif event.start_with?('falls')
    key = memo.keys.max
    memo[key].record[timestamp.min] = '#'
  else
    key = memo.keys.max
    i = timestamp.min - 1
    until memo[key].record[i] == '#'
      memo[key].record[i] = '#'
      i -= 1
    end
  end
end

counts = records.each_with_object(Hash.new(0)) do |(_, v), memo|
  memo[v.guard_id] += v.record.count('#')
end

sleepy_guard = sleepy_hours = 0
counts.each do |guard_id, hours|
  if hours > sleepy_hours
    sleepy_guard = guard_id
    sleepy_hours = hours 
  end
end

sleepy_records = records.values.select { |guard_record| guard_record.guard_id == sleepy_guard }.map(&:record)
minutes = sleepy_records.each_with_object(Array.new(60, 0)) do |sleepy_record, memo|
  sleepy_record.chars.each_with_index { |what, i| memo[i] += 1 if what == '#' }
end

puts minutes.find_index(minutes.max) * sleepy_guard

sleeps_by_minute = records.values.each_with_object({}) do |guard_record, memo|
  memo[guard_record.guard_id] = Array.new(60, 0)
end

 records.values.each_with_object(sleeps_by_minute) do |guard_record, memo|
  guard_record.record.chars.each_with_index { |what, i| memo[guard_record.guard_id][i] += 1 if what == '#' }
end

max_count = max_minute = max_guard = 0
sleeps_by_minute.each do |guard_id, sleep_counts|
  max = sleep_counts.max
  min = sleep_counts.find_index(max)
  if max > max_count
    max_minute = min
    max_count = max
    max_guard = guard_id
  end
end

puts max_guard * max_minute
