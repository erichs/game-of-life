#!/usr/bin/env ruby

require 'debugger'

class InvalidInput < Exception
end

class Grid

  def initialize columns, rows, file=nil
    @columns = columns
    @rows    = rows
    @grid    = populate_from file
    introduce_neighbors!
  end

  def display
    [].tap { |output|
      output << @grid.map{|row| row.map{|cell| (cell.is_alive? ? '*' : '.')}.join}
    }.join("\n")
  end

  def next!
    each_cell do |cell|
      cell.prepare_to_mutate
    end

    each_cell do |cell|
      cell.mutate!
    end
  end

  private

    def populate_from( file )
      [].tap do |grid|
        if File.exist? file.to_s
          File.read(file).split("\n").each do |row|
            grid << row.split(//).map{|state| Cell.new(state)}
          end
        else
          @rows.times.each do |row|
            grid << @columns.times.map {|x| Cell.new('.')}
          end
        end
      end
    end

    def each_cell
      @grid.each do |row|
        row.each do |cell|
          yield cell
        end
      end
    end

    def each_cell_with_indexes
      @grid.each_with_index do |row, row_idx|
        row.each_with_index do |cell, col_idx|
          yield cell, row_idx, col_idx
        end
      end
    end

    def add_top_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx - 1][col_idx]) if row_idx > 0
    end

    def add_top_left_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx - 1][col_idx - 1]) if row_idx > 0 && col_idx > 0
    end

    def add_top_right_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx - 1][col_idx + 1]) if row_idx > 0 && col_idx < (@columns - 1)
    end

    def add_left_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx][col_idx - 1]) if col_idx > 0
    end

    def add_right_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx][col_idx + 1]) if col_idx < @columns - 1
    end

    def add_bottom_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx + 1][col_idx]) if row_idx < @rows - 1
    end

    def add_bottom_right_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx + 1][col_idx + 1]) if row_idx < (@rows - 1) && col_idx < (@columns - 1)
    end

    def add_bottom_left_neighbor(cell, row_idx, col_idx)
      (cell.neighbors << @grid[row_idx + 1][col_idx - 1]) if row_idx < (@rows - 1) && col_idx > 0
    end

    def introduce_neighbors!
      each_cell_with_indexes do |cell, row_idx, col_idx|
        add_top_neighbor          cell, row_idx, col_idx
        add_top_left_neighbor     cell, row_idx, col_idx
        add_top_right_neighbor    cell, row_idx, col_idx
        add_left_neighbor         cell, row_idx, col_idx
        add_right_neighbor        cell, row_idx, col_idx
        add_bottom_neighbor       cell, row_idx, col_idx
        add_bottom_left_neighbor  cell, row_idx, col_idx
        add_bottom_right_neighbor cell, row_idx, col_idx
      end
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

  def prepare_to_mutate
    die_if_underpopulated
    die_if_overpopulated
    revive_if_born
  end

  def mutate!
    @alive = @next_state
  end

  def meaning
    42
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
