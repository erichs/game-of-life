#!/usr/bin/env ruby

require 'debugger'

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
      output << @grid.map{|row| row.map{|cell| (cell.is_alive? ? '*' : '.')}.join}
    }.join("\n")
  end

  def meaning
    42
  end

  def next!
    @grid.each do |row|
      row.each do |cell|
        cell.mutate!
      end
    end

    @grid.each do |row|
      row.each do |cell|
        cell.enforce!
      end
    end
  end

  private
    def build_grid file
      grid = []
      if File.exist? file.to_s
        File.read(file).split("\n").each do |row|
          grid << row.split(//).map{|state| Cell.new(state)}
        end
      else
        @rows.times.each do |row|
          grid << @columns.times.map {|x| Cell.new('.')}
        end
      end
      grid.each_with_index do |row, row_idx|
        row.each_with_index do |cell, col_idx|
          if row_idx > 0
            cell.neighbors << grid[row_idx - 1][col_idx]       # top neighbor
            if col_idx > 0
              cell.neighbors << grid[row_idx - 1][col_idx - 1] # top-left neighbor
            end
            if col_idx < @columns - 1
              cell.neighbors << grid[row_idx - 1][col_idx + 1] # top-right neighbor
            end
          end
          if col_idx > 0
            cell.neighbors << grid[row_idx][col_idx - 1]       # left neighbor
          end
          if col_idx < @columns - 1
            cell.neighbors << grid[row_idx][col_idx + 1]       # right neighbor
          end
          if row_idx < @rows - 1
            cell.neighbors << grid[row_idx + 1][col_idx]       # bottom neighbor
            if col_idx > 0
              cell.neighbors << grid[row_idx + 1][col_idx - 1] # bottom-left neighbor
            end
            if col_idx < @columns - 1
              cell.neighbors << grid[row_idx + 1][col_idx + 1] # bottom-right neighbor
            end
          end
        end
      end
      grid
    end
end

class Cell
  attr_accessor :neighbors, :next_state

  def initialize state
    @alive = state == '*'
    @next_state = @alive
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

  def enforce!
    @alive = @next_state
  end

  private
    def die!
      @next_state = false
    end

    def revive!
      @next_state = true
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
