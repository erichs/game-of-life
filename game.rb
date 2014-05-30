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
  attr_accessor :neighbors

  def initialize state
    @alive = state == '*'
    @neighbors = []
  end

  def is_alive?
    @alive
  end

  def mutate!
    die_if_underpopulated
    die_if_overpopulated
    revive_if_born
  end

  private
    def die!
      @alive = false
    end

    def revive!
      @alive = true
    end

    def die_if_underpopulated
      die! if num_alive_neighbors < 2
    end

    def die_if_overpopulated
      die! if num_alive_neighbors > 3
    end

    def revive_if_born
      revive! if num_alive_neighbors == 3
    end

    def num_alive_neighbors
      neighbors.select{|n| n.is_alive?}.count
    end
end

if __FILE__ == $0
  # this will only run if the script was the main, not load'd or require'd
  puts Grid.new(8,4).display
end
