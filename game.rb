#!/usr/bin/env ruby

class Grid

  def initialize columns, rows, file=nil
    @columns = columns
    @rows    = rows
    @grid    = populate_from file
    introduce_neighbors!
    @history = []
    @max_history_size = 3
    @history << display
    @generation = 1
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

    update_history
  end

  private


    def update_history
      @generation += 1
      output = display
      fail "Generation #{@generation}, cycle repeats." if @history.include? output
      @history << output
      @history.shift if @history.size > @max_history_size
    end

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

    def grid_neighbors_of(row, col)
      [].tap do |neighbors|
        [ row - 1, row, row + 1 ].each do |neighbor_row|
          [ col - 1, col, col + 1 ].each do |neighbor_col|
            next if outside_grid?(neighbor_row, neighbor_col)
            next if row == neighbor_row and col == neighbor_col
            neighbors << @grid[neighbor_row][neighbor_col]
          end
        end
      end
    end

    def outside_grid?(row, col)
      row < 0 || row > (@rows - 1) || col < 0 || col > (@columns - 1)
    end

    def introduce_neighbors!
      each_cell_with_indexes do  |cell, row_idx, col_idx|
         cell.neighbors = grid_neighbors_of row_idx, col_idx
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
