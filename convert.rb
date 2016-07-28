#!/usr/bin/env ruby

require 'JSON'
# Array position corresponds to the key name of that field position
FIXED_FIELD_NAMES = %W(lat long foo bar baz)
FIXED_FIELD_LENGTH = 10

result = []
file_to_read = File.expand_path(ARGV.first)

raise "could not find file #{file_to_read}" unless File.exists?(file_to_read)

File.open(file_to_read, "r").each_line do |line|
  partitions = []
  line.chomp! # removes trailing \n
  line.each_char.each_with_index do |char, i|
    # Insert new partition if we hit fixed field length
    if i % FIXED_FIELD_LENGTH == 0
      # nil check for first iteration
      unless partitions[-1].nil?
        partitions[-1].strip! # remove trailing whitespace
      end
      partitions << ""
    end
    partitions[-1] << char
  end

  if partitions.length != FIXED_FIELD_NAMES.length
    raise "Invalid line `#{line}', not enough or too many fields"
  end

  object = {}
  FIXED_FIELD_NAMES.zip(partitions) { |key, value| object.merge!(key => value) }
  result << object
end

puts({"objects" => result}.to_json)
