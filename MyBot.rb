$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
	# your turn code here
    map = ai.map

    foods = map.food
    #hills = map.hills
    enemies = map.enemy_ants
    my_ants = map.my_ants


    # TODO, keep ants between turns
    #idle_ants = my_ants.reject { |ant| ant.busy? }

    idle_ants = my_ants

    # Send idle ants to get food
    while(foods.any? and idle_ants.any?)
      food = foods.shift
      # Cheaper to sort an array by distance than path it
      ant = idle_ants.sort_by { |ant| ant.square.distance(food) }.shift
      # Send them to get food, doesn't matter what
      ant.path( lambda { |square| square.food? } )
      ant.go!
    end


    # Move the idle ants somewhere...
    idle_ants.each do |ant|
      ant.path( lambda { |square| square.distance(ant.square) > 3 } )
      ant.go!
    end
end
