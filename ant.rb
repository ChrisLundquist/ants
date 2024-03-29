require 'ants'
require 'a_star'
class Ant
    # Owner of this ant. If it's 0, it's your ant.
    attr_accessor :owner
    # Square this ant sits on.
    attr_accessor :square

    attr_accessor :alive

    attr_accessor :orders

    def self.heuristic_cost_estimate(spot, new_spot)
        return -100 if new_spot.hill? and new_spot.hill? != 0
        return -10 if new_spot.food?
        # We really don't want to step on our own hill
        return 100 if new_spot.hill and new_spot.hill? == 0
        return 10 if new_spot.ant?
        return 0
    end

    def self.path(start,goal)
      @@path_finder ||= AStar.new(
        lambda {|spot| spot.walkable_neighbors }, 
        lambda {|spot,new_spot| Ant.heuristic_cost_estimate(spot,new_spot) }, 
        lambda {|goal, new_spot| if(goal.is_a?(Square)) then goal.distance(new_spot) else 1 end } 
      )
      @@path_finder.find_path(start,goal)
    end

    def initialize(options)
      alive = options[:alive]
      owner = options[:owner]
      square = options[:square]
      raise ArgumentError.new("Require :alive,:owner,:square") unless options.keys.count == 3

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
        @orders = Ant.path(square,destination)
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
        next_square.food = nil
        next_square.hill = nil unless next_square.hill? == 0
    end

    def go!
        # get rid of this square of the path
        order(orders.shift) if orders.any?
    end
end
