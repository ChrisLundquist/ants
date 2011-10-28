require "ants"
describe Ant do

  before(:each) do
    @map = Map.new(:rows => 10, :cols => 10)
    @ant = Ant.new(:owner => 0, :square => @map[0][0], :alive => true)
  end

  it "should queue a path when told to move to a given tile" do
    @ant.orders.count.should == 0
    @ant.path(@map[1][1])
    @ant.orders.count.should_not == 0
  end

  it "should update our map with the next turn position when told to go" do
    start = @map[0][0]
    @ant.orders.count.should == 0
    @ant.path(@map[1][1])
    square = @ant.orders.first
    square.ant.should be_nil
    @ant.go!
    square.ant.should == @ant
    start.ant.should be_nil
  end

  it "should be able path to a lambda expression" do
    food_square = @map[0][5]
    food_square.food = true
    @ant.path( lambda { |square| square.food? })
    @ant.orders.last.should == food_square
  end
end
