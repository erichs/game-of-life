#!/usr/bin/env ruby

class InvalidInput < Exception
end

class Grid

  def initialize columns, rows
    @columns = columns
    @rows = rows

    @grid = []
    rows.times.each do |row|
      @grid << columns.times.map {|x| '.'}
    end
  end

  def display
    output = []
    @grid.each do |row|
      output << row.join
    end
    output.join ("\n")
  end

  def meaning
    42
  end

end


if __FILE__ == $0
  # this will only run if the script was the main, not load'd or require'd
  puts Grid.new(8,4).display
end
