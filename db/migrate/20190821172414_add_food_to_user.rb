class AddFoodToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :food, :integer, :default =>  100
  end
end
