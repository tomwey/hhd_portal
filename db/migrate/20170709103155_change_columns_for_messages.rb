class ChangeColumnsForMessages < ActiveRecord::Migration
  def change
    remove_index :messages, :user_id if index_exists?(:messages, :user_id)
    remove_column :messages, :user_id
    
    add_column :messages, :to_users, :integer, array: true, default: []
    add_column :messages, :link, :string
  end
end
