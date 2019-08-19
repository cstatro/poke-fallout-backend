class CreatePokemons < ActiveRecord::Migration[5.2]
  def change
    create_table :pokemons do |t|
      t.string :name
      t.integer :face_id
      t.integer :body_id
      t.integer :mother_id
      t.integer :father_id
      t.string :gender
      t.integer :owner_id

      t.timestamps
    end
  end
end
