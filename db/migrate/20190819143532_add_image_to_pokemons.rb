class AddImageToPokemons < ActiveRecord::Migration[5.2]
  def change
    add_column :pokemons, :image_url, :string
  end
end
