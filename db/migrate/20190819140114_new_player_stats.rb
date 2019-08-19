class NewPlayerStats < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :facility_tier, :integer, default: 1
    add_column :users, :authority, :integer, default: 100
    add_column :users, :facility_cleanliness, :integer, default: 100
    
  end
end
