class AddColumnsToPokemons < ActiveRecord::Migration[5.2]
  def change
    add_column :pokemons, :current_hp, :integer
    add_column :pokemons, :nourishment, :integer
  end
end
