require 'ants'
class Square
    # Ant which sits on this square, or nil. The ant may be dead.
    attr_accessor :ant
    # Which row this square belongs to.
    attr_accessor :row
    # Which column this square belongs to.
    attr_accessor :col

    attr_accessor :water, :food, :hill, :map

    def to_s
      "#{type} (#{col},#{row})"
    end

    def type
      return :water if water?
      return :food if food?
      return :hill if hill?
      return :ant if ant?
    end

    def ==(rhs)
      if rhs.is_a?(Square)
          return col == rhs.col && row == rhs.row
      elsif rhs.is_a?(Proc)
          return rhs.call(self)
      end
    end

    def initialize water, food, hill, ant, row, col, map
        @water, @food, @hill, @ant, @row, @col, @map = water, food, hill, ant, row, col, map
    end

    # Returns true if this square is not water. Square is passable if it's not water, it doesn't contain alive ants and it doesn't contain food.
    def land?; !@water; end
    # Returns true if this square is water.
    def water?; @water; end
    # Returns true if this square contains food.
    def food?; @food; end
    # Returns owner number if this square is a hill, false if not
    def hill?; @hill; end
    # Returns true if this square has an alive ant.
    def ant?; @ant and @ant.alive?; end;

    # Returns a square neighboring this one in given direction.
    def neighbor direction
        direction=direction.to_s.upcase.to_sym # canonical: :N, :E, :S, :W

        return case direction
        when :N
           north()
        when :E
           east()
        when :S
           south()
        when :W
           west()
        else
            raise 'incorrect direction'
        end
    end

    def north
      row, col = @map.normalize(@row - 1, @col)
      return @map[row][col]
    end

    def east
      row, col = @map.normalize(@row, @col+1)
      return @map[row][col]
    end

    def south
      row, col = @map.normalize(@row + 1, @col)
      return @map[row][col]
    end

    def west
      row, col = @map.normalize(@row, @col - 1)
      return @map[row][col]
    end

    def walkable_neighbors
        neighbors = [north,east,south,west].reject { |square| square.water? or (square.ant? and square.ant.mine?) }
        neighbors
    end

    def distance(other_square)
        row_distance(other_square) + col_distance(other_square)
    end

    def row_distance(other_square)
      row_delta = (@row - other_square.row).abs
      return [row_delta, @map.rows - row_delta].min
    end

    def col_distance(other_square)
      col_delta = (@col - other_square.col).abs
      return [col_delta, @map.cols - col_delta].min
    end
end
