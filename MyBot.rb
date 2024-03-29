$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
    map = ai.map
    my_hill = map.my_hill
    foods = map.food
    enemies = map.enemy_ants
    enemy_hills = map.enemy_hills.values
    my_ants = map.my_ants
    my_ant_count = my_ants.count
    food_count = foods.count


    # TODO, keep ants between turns
    #idle_ants = my_ants.reject { |ant| ant.busy? }

    idle_ants = my_ants

    # Send idle ants to get food
    [food_count,idle_ants.count,30].min.times do 
      food = foods.shift
      # Cheaper to sort an array by distance than path it
      idle_ants = idle_ants.sort_by { |ant| ant.square.distance(food) }
      ant = idle_ants.shift
      # Send them to get food, doesn't matter what
      ant.path( lambda { |square| square.food? } )
      ant.go!
    end

    idle_ants.reject! { |ant| ant.busy? }

    # Do we know about any enemy bases captain?
#    if(enemy_hills.count > 0 and idle_ants.any?)
#      enemy_hills = enemy_hills.sort_by { |hill| hill.distance(my_hill) } 
#      target = enemy_hills.first
#
#      # Make half our idle ants soldiers, the half closer to their base
#      soldier_count = [15,idle_ants.count / 2].min
#      soldiers = idle_ants.sort_by { |ant| ant.square.distance(target) }[0..soldier_count]
#
#      soldiers.each do |ant|
#        break if target.ant? and target.ant.mine?
#        # Move closer
#        ant.path(lambda { |square| square.distance(target) < ant.square.distance(target) or square == target })
#        ant.go!
#      end
#    end

    idle_ants.reject! { |ant| ant.busy? }

#    scout_count = [10,idle_ants.count].min
#    scouts = idle_ants[0..scout_count]
#
#    scouts.each do |ant|
#      ant.path( lambda { |square| square.distance(my_hill) > ant.square.distance(my_hill) + 1})
#      ant.go!
#    end
#    idle_ants.reject! { |ant| ant.busy? }

    # Move the idle ants somewhere...
      ai.phalanx(idle_ants)
end

