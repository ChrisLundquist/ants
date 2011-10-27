require 'ants'
require 'a_star'
class Ant
    # Owner of this ant. If it's 0, it's your ant.
    attr_accessor :owner
    # Square this ant sits on.
    attr_accessor :square

    attr_accessor :alive

    attr_accessor :orders
    attr_accessor :path_finder


    def initialize(options)
      alive = options[:alive]
      owner = options[:owner]
      square = options[:square]
      raise ArgumentError.new("Require :alive,:owner,:square") unless options.keys.count == 3

        @path_finder ||= AStar.new(
            lambda {|spot| spot.walkable_neighbors }, 
            lambda {|spot,new_spot| heuristic_cost_estimate(spot,new_spot) }, 
            lambda {|goal, new_spot| goal.distance(new_spot) } 
        )
        @alive, @owner, @square = alive, owner, square
        @orders = Array.new
        square.ant = self
    end

    # True if ant is alive.
    def alive?; @alive; end
    # True if ant is not alive.
    def dead?; !@alive; end

    # Equivalent to ant.owner==0.
    def mine?; owner==0; end
    # Equivalent to ant.owner!=0.
    def enemy?; owner!=0; end

    # Returns the row of square this ant is standing at.
    def row; @square.row; end
    # Returns the column of square this ant is standing at.
    def col; @square.col; end

    def stop!
        orders = []
    end

    def busy?
        orders.length > 0
    end

    def idle?
        orders.length == 0
    end

    # AI path to the destination square
    def path(destination)
        @orders = @path_finder.find_path(square,destination)
    end

    # TODO
    def heuristic_cost_estimate(spot, new_spot)
        return -10 if new_spot.food?
        return 10 if new_spot.hill?
        return 10 if new_spot.ant?
        return 0
    end

    def order(next_square)
        direction = case next_square
                    when square.north
                        :N
                    when square.east
                        :E
                    when square.south
                        :S
                    when square.west
                        :W
                    else
                        STDERR.puts "invalid path!:  #{next_square}"
                    end

        STDOUT.puts "o #{row} #{col} #{direction.to_s.upcase}"
        square.ant = nil
        next_square.ant = self
    end

    def go!
        # get rid of this square of the path
        order(orders.shift) if orders.any?
    end
end
