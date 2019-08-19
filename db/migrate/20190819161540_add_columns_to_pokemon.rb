class AddColumnsToPokemon < ActiveRecord::Migration[5.2]
  def change
    add_column :pokemons, :level, :integer
    add_column :pokemons, :loyalty, :integer
  end
end
