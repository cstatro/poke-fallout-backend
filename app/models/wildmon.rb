class Wildmon < ApplicationRecord


    



    def self.inhabitants_by_level(habitat, level)
        self.all.select{|wildmon| wildmon.habitat == habitat && wildmon.minimum_level <= level}
    end

    def self.random_wild_data(habitat, level)

        possible = self.inhabitants_by_level(habitat, level)
        capture_total = possible.inject(0.0){|total, value| total + value.capture_rate}

        rando = rand
        incrementor = 0
        head_id = possible.find do |inhabitant|
            incrementor += inhabitant.capture_rate/capture_total
            rando <= incrementor
        end.species_id

        rando = rand
        incrementor = 0
        body_id = possible.find do |inhabitant|
            incrementor += inhabitant.capture_rate/capture_total
            rando <= incrementor
        end.species_id

        {head_id: head_id, body_id: body_id}
            
    end


    def self.check_stats(head_id, body_id, level)
        
        head = PokeApi.get(pokemon: head_id)
        body =  PokeApi.get(pokemon: body_id)

        attack = ((head.stats[4].base_stat + body.stats[4].base_stat) * level / 100) + 5
        defense = ((head.stats[3].base_stat + body.stats[3].base_stat) * level / 100) + 5

        {attack: attack, defense: defense}

    end



   





end
