#!/usr/bin/env ruby

class Game
  def initialize(inputfile, silent: false, max_history: 3)
    @grid = Grid.new(inputfile)
    @history = []
    @max_history_size = max_history
    @history << @grid.display
    @generation = 1
    @silent = silent
    @delay = @silent ? 0 : 0.05

    trap "SIGINT" do
      game_over!
    end
  end

  def run!
    while true
      puts @grid.display unless @silent
      sleep @delay
      @grid.next!
      update_history
    end
  end

  private

    def game_over!(cycling: false)
      message = "Generation #{@generation}"
      message += ", cycle repeats." if cycling
      fail GameOver, message
    end

    def update_history
      @generation += 1
      output = @grid.display
      game_over!(cycling: true) if @history.include? output
      @history << output
      @history.shift if @history.size > @max_history_size
    end
end

class Grid

  def initialize(inputfile=nil)
    fail "No file? #{inputfile}" unless File.exist? inputfile
    input = File.read(inputfile).split
    @rows = input.count
    @columns = input.first.split(//).count
    @grid    = populate_from input
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

    def populate_from( input_array )
      [].tap do |grid|
        input_array.each do |row|
          grid << row.split(//).map{|state| Cell.new(state)}
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

class GameOver < Exception; end

if __FILE__ == $0
  silent = (ARGV[1] && ARGV[1] == '-s') ? true : false
  Game.new(ARGV[0], silent: silent).run!
end
