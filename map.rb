require "ants"
class Map
  attr_accessor :rows, :cols, :grid, :food, :hills

  def initialize(attributes)
    raise ArguementError.new("Need :rows, and :cols") unless attributes[:rows] and attributes[:cols]

    @rows = attributes[:rows]
    @cols = attributes[:cols]
    @grid = Array.new(@rows){|row| Array.new(@cols){|col| Square.new false, false, false, nil, row, col, self } }
    @food = Array.new
    @hills = Array.new
  end

  def [](index)
      @grid[index]
  end

  def reset!
    @food = Array.new
    @hills = Array.new

    @grid.each do |row|
      row.each do |square|
        square.food=false
        square.ant=nil
        square.hill=false
      end
    end
  end

    # If row or col are greater than or equal map width/height, makes them fit the map.
    #
    # Handles negative values correctly (it may return a negative value, but always one that is a correct index).
    #
    # Returns [row, col].
    def normalize row, col
        [row % @rows, col % @cols]
    end
end
