class AddFromUserIdToPartinViewLogs < ActiveRecord::Migration
  def change
    add_column :partin_view_logs, :from_user_id, :integer
    add_index :partin_view_logs, :from_user_id
  end
end
