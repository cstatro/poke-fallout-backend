class User < ApplicationRecord
    has_many :pokemons
    validates :name, uniqueness: true

    def pokemon_capacity
        self.facility_tier * 2
    end

    def living_pokemon
        self.pokemons.select{|poke| poke.alive}
    end
end
