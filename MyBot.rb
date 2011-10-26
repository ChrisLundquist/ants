$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
	# your turn code here
    map = ai.map.flatten

    foods = map.select { |square| square.food? }
    enemies = ai.enemy_ants

    idle_ants = ai.my_ants.reject { |ant| ant.busy? }

    # Send idle ants to get food
    idle_ants.each do |ant|
      while(foods.any? and ant.idle?)
        ant.move!(foods.shift)
      end
    end
end
