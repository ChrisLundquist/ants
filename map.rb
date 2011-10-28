require "ants"
class Map
  attr_accessor :rows, :cols, :grid, :food, :my_ants, :enemy_ants

  def initialize(attributes)
    raise ArgumentError.new("Need :rows, and :cols") unless attributes[:rows] and attributes[:cols]

    @rows = attributes[:rows]
    @cols = attributes[:cols]
    @grid = Array.new(@rows){|row| Array.new(@cols){|col| Square.new false, false, false, nil, row, col, self } }
    @food = Array.new
    @my_ants = Array.new
    @enemy_ants = Array.new
  end

  def [](index)
      @grid[index]
  end

  def hills
    @hills ||= grid.flatten.select { |square| square.hill? }
  end

  def reset!
    @food = Array.new
    @hills = nil
    @my_ants = Array.new
    @enemy_ants = Array.new

    @grid.each do |row|
      row.each do |square|
        #square.food=false
        square.ant=nil
        #square.hill=false
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
