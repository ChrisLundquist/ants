require "ants"
describe AStar do
  before(:each) do
    @map = Map.new(:rows => 10, :cols => 10)
    @ant = Ant.new(:alive => true, :owner => 0, :square => @map[0][0])
    @a_star||= AStar.new(
      lambda {|spot| spot.walkable_neighbors },
      lambda {|spot,new_spot| Ant.heuristic_cost_estimate(spot,new_spot) },
      lambda {|goal, new_spot| if(goal.is_a?(Square)) then goal.distance(new_spot) else 1 end }
    )

  end

  it "should be able to find a path to the next square, even if it wraps around the map edge" do
    target = @map[0][1]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 1
    orders.first.should == target

    target = @map[0][-1]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 1
    orders.first.should == target


    target = @map[1][0]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 1
    orders.first.should == target


    target = @map[-1][0]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 1
    orders.first.should == target
  end

  it "should be able to find optimal simple paths" do
    target = @map[0][5]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 5

    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)

    target = @map[0][-5]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 5
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)

    target = @map[5][0]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 5
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)

    target = @map[-5][0]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 5
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)
  end

  it "should be able to find optimal diagonal paths" do
    target = @map[5][5]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 10

    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)

    target = @map[5][-5]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 10
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)

    target = @map[5][5]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 10
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)

    target = @map[-5][5]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 10
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)
  end

  it "should be able to path around water" do
    # Make the direct path water
    @map[0][1].water = true
    # find a path to the other side of the water
    target = @map[0][2]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 4
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)
  end

  it "should go the short way around water" do
    # Make the direct path water
    @map[0][1].water = true
    # And below it, so we should go around the top
    @map[1][1].water = true
    # find a path to the other side of the water
    target = @map[0][2]
    orders = @a_star.find_path(@ant.square,target)
    orders.count.should == 4
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)
  end

  it "should path around friendly ants" do
    # Put an ant in the way
    @ant2 = Ant.new(:alive => true, :owner => 0, :square => @map[0][1])

    target = @map[0][2]
    orders = @a_star.find_path(@ant.square,target)
    @ant.orders.should_not include(@ant2.square)
    orders.count.should == 4
    # Make sure the last square is what we wanted
    orders.last.should == target
    # Make sure we can get to the first square
    @ant.square.walkable_neighbors.should include(orders.first)
  end
end
