class RemoveSomeColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_index :users, :wx_id if index_exists?(:users, :wx_id)
    remove_column :users, :wx_id
    remove_column :users, :wx_avatar
  end
end
