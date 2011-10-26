require "ants"

describe Square do
  before(:each) do
    @map = Map.new(:rows => 10, :cols => 10)
  end

  context "When calculating distances between squares" do
    it "should calculate distance to squares in the same row" do
      @map[0][0].distance(@map[0][5]).should == 5
      @map[0][0].distance(@map[0][3]).should == 3
    end

    it "should calculate distances that wrap around the column" do
      @map[0][0].distance(@map[0][-3]).should == 3
    end

    it "should calculate distances that wrap around the row" do
      @map[0][0].distance(@map[-3][0]).should == 3
    end

    it "should calculate diagonal distances as the difference in X plus the difference in Y since this is the minimum number of moves" do
      @map[0][0].distance(@map[1][1]).should == 2
      @map[0][0].distance(@map[1][2]).should == 3
      @map[0][0].distance(@map[2][1]).should == 3
      @map[0][0].distance(@map[2][2]).should == 4
      @map[0][0].distance(@map[-1][-1]).should == 2
    end

    # This is hard because after the first [] we are an Array
    #xit "should be equal to the same square minus the map size" do
    #  @map[0][0].distance(@map[0][5 + @map.rows]).should == 5
    #  @map[0][0].distance(@map[0][3 + @map.rows]).should == 3
    #end
  end

  context "when returning neighbors" do
    it "should return the north neighbor" do
      @map[1][0].north.should == @map[0][0]
    end

    it "should return the south neighbor" do
      @map[0][0].south.should == @map[1][0]
    end

    it "should return the east neighbor" do
      @map[0][0].east.should == @map[0][1]
    end

    it "should return the west neighbor" do
      @map[0][1].west.should == @map[0][0]
    end

    it "should return 4 neighbors if each is land" do
      # Test the "corner cases" :)
      neighbors = @map[0][0].walkable_neighbors
      neighbors.count.should == 4
      neighbors.should include @map[0][1]
      neighbors.should include @map[1][0]
      neighbors.should include @map[-1][0]
      neighbors.should include @map[0][-1]

      @map[0][@map.cols - 1].walkable_neighbors.count.should == 4
      @map[@map.rows - 1][0].walkable_neighbors.count.should == 4
      @map[@map.rows - 1][@map.cols - 1].walkable_neighbors.count.should == 4

      # Test a point in the middle somewhere
      @map[2][2].walkable_neighbors.count.should == 4
    end

    it "should only return land tiles" do
      @map[0][1].water = true
      @map[0][0].walkable_neighbors.count.should == 3

      @map[1][0].water = true
      @map[0][0].walkable_neighbors.count.should == 2

      @map[-1][0].water = true
      @map[0][0].walkable_neighbors.count.should == 1

      @map[0][-1].water = true
      @map[0][0].walkable_neighbors.count.should == 0
    end
  end
end
