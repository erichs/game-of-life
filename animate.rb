#!/usr/bin/env ruby
require './game'
file = ARGV[0]
fail "No file? #{file}" unless File.exist? file
f = File.read(file).split
rows = f.count
cols = f.first.split(//).count

grid = Grid.new(rows, cols, file)
while true
  puts grid.display
  sleep 1
  grid.next!
end
