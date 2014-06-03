require 'simplecov'
require 'turn/autorun'

SimpleCov.start do
  add_filter 'vendor'
end

require './game'

describe Grid do

  it "generates a blank nxm matrix when no input state is given" do
    grid = Grid.new(8,4)
    disp = grid.display
    rows = disp.split("\n")
    rows.count.must_equal 4
    rows[0].scan(/\./).count.must_equal 8
  end

  it "accepts input from a file" do
    grid = Grid.new( 9, 5, 'examples/9_by_5_matrix.txt')
    disp = grid.display
    disp.scan(/\*/).count.must_equal 4
  end

  it "calculates the next generation" do
    grid = Grid.new( 5, 5, 'examples/5_by_5_matrix.txt')
    grid.next!
    disp = grid.display
    disp.scan(/\*/).count.must_equal 6
    grid = Grid.new( 5, 5, 'examples/5_by_5_oscillator.txt')
    grid.next!
    disp = grid.display
    disp.scan(/\*/).count.must_equal 3
    output = disp.split("\n")
    output[2][1].must_equal '.'
    output[2][3].must_equal '.'
    output[1][2].must_equal '*'
    output[3][2].must_equal '*'
  end

  it "fails when output repeats" do
    grid = Grid.new( 5, 5, 'examples/5_by_5_oscillator.txt')
    proc {
      grid.next!
      grid.next!
      grid.next!
    }.must_raise RuntimeError
  end
end

describe Cell do
  it "is self aware" do
    cell = Cell.new('*')
    cell.is_alive?.must_equal true
  end

  it "can have neighbors" do
    cell = Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('.')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('.')
    cell.neighbors.length.must_equal 4
  end

  it "dies with less than 2 live neighbors" do
    cell = Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('.')
    cell.neighbors << Cell.new('.')
    cell.neighbors << Cell.new('.')
    cell.prepare_to_mutate
    cell.mutate!
    cell.is_alive?.must_equal false
  end

  it "dies with more than 3 live neighbors" do
    cell = Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.prepare_to_mutate
    cell.mutate!
    cell.is_alive?.must_equal false
  end

  it "lives if 2 or 3 neighbors live" do
    cell = Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('.')
    cell.prepare_to_mutate
    cell.mutate!
    cell.is_alive?.must_equal true
    cell.neighbors.shift
    cell.prepare_to_mutate
    cell.mutate!
    cell.is_alive?.must_equal true
  end

  it "reanimates with 3 live neighbors" do
    cell = Cell.new('.')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('*')
    cell.neighbors << Cell.new('.')
    cell.prepare_to_mutate
    cell.mutate!
    cell.is_alive?.must_equal true
  end

end
