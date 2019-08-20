class PokemonsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name,:user,:hp,:gender
end
