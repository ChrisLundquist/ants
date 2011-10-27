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
    hills = map.hills
    enemies = map.enemy_ants
    my_ants = map.my_ants

    idle_ants = my_ants.reject { |ant| ant.busy? }

    # Send idle ants to get food
    idle_ants.each do |ant|
      while(foods.any? and ant.idle?)
        ant.path(foods.shift)
        ant.go!
      end
    end
end
