class AddToUsersToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :to_users, :integer, array: true, default: []
    add_index :notifications, :to_users, using: 'gin'
  end
end
