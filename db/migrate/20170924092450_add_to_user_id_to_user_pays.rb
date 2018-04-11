class AddToUserIdToUserPays < ActiveRecord::Migration
  def change
    add_column :user_pays, :to_user_id, :integer
    add_index :user_pays, :to_user_id
  end
end
