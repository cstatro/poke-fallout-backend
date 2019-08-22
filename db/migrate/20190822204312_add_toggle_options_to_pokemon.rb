class AddToggleOptionsToPokemon < ActiveRecord::Migration[5.2]
  def change
    add_column :pokemons, :current_action, :string, default: "Idle"
    add_column :pokemons, :food_policy, :integer, default: 1
  end
end
