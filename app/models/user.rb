class User < ApplicationRecord
    has_many :pokemons
    def pokemon_capacity
        self.facility_tier * 2
    end
end
