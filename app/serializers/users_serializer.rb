class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name,:authority,:facility_tier,:facility_cleanliness,:pokemon_capacity,:pokemons, :food
end
