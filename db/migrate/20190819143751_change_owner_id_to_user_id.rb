class ChangeOwnerIdToUserId < ActiveRecord::Migration[5.2]
  def change
    rename_column :pokemons,:owner_id,:user_id
  end
end
