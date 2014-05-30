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
end