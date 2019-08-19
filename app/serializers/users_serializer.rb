class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name,:authority,:facility_tier,:facility_cleanliness,:pokemon_capacity,:pokemons
end
