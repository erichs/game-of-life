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

  # it "calculates the next generation"
end

describe Cell do
  it "is self aware" do
    cell = Cell.new('*')
    cell.is_alive?.must_equal true
  end
end