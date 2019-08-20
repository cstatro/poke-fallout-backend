class AddAliveToPokemons < ActiveRecord::Migration[5.2]
  def change
    add_column :pokemons, :alive, :boolean
  end
end
