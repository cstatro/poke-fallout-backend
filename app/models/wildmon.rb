class Wildmon < ApplicationRecord


    @@habitats = ["cave", "forest", "grassland", "mountain", "rare", "rough-terrain", "sea", "urban", "waters-edge"]



    def self.inhabitants_by_level(habitat, level)
        self.all.select{|wildmon| wildmon.habitat == habitat && wildmon.minimum_level <= level}
    end

    def self.random_encounters_for(habitat, level, number, user_id)
        possible = self.inhabitants_by_level(habitat, level)
        capture_total = possible.inject(0.0){|total, value| total + value.capture_rate}

        choices = []

        (number * 2).times do
            rando = rand
            incrementor = 0
            choices << possible.find do |inhabitant|
                incrementor += inhabitant.capture_rate/capture_total
                rando <= incrementor
            end.species_id
        end

        choices.each_slice(2).map {|pair| Pokemon.generate(pair[0], pair[1], level, user_id)}

    end

    def self.starters_for(user_id)
        others = Wildmon.inhabitants_by_level("grassland", 5)
        grass = [1, others.sample.species_id].shuffle
        fire = [4, others.sample.species_id].shuffle
        water = [7, others.sample.species_id].shuffle
        [Pokemon.generate(grass[0], grass[1], 5, user_id), Pokemon.generate(fire[0], fire[1], 5, user_id), Pokemon.generate(water[0], water[1], 5, user_id)]
    end





end
