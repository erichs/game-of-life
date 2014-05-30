#!/usr/bin/env ruby

class InvalidInput < Exception
end

class Grid

  def initialize columns, rows, file=nil
    @columns = columns
    @rows    = rows
    @grid    = build_grid file
  end

  def display
    [].tap { |output|
      output << @grid.map{|row| row.join}
    }.join("\n")
  end

  def meaning
    42
  end

  private
    def build_grid file
      grid = []
      if File.exist? file.to_s
        File.read(file).split("\n").each do |row|
          grid << row.split(//)
        end
      else
        @rows.times.each do |row|
          grid << @columns.times.map {|x| '.'}
        end
      end
      grid
    end
end

class Cell
  def initialize state
    @state = state
  end
  def is_alive?
    @state == '*'
  end
end

if __FILE__ == $0
  # this will only run if the script was the main, not load'd or require'd
  puts Grid.new(8,4).display
end
