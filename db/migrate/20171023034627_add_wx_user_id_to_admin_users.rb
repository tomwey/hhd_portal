class AddWxUserIdToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :wx_user_id, :integer
    add_index :admin_users, :wx_user_id
  end
end
