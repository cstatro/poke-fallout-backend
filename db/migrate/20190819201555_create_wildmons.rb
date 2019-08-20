class CreateWildmons < ActiveRecord::Migration[5.2]
  def change
    create_table :wildmons do |t|
      t.integer :species_id
      t.string :habitat
      t.integer :minimum_level
      t.integer :capture_rate

      t.timestamps
    end
  end
end
