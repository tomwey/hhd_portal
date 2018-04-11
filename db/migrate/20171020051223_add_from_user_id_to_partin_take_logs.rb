class AddFromUserIdToPartinTakeLogs < ActiveRecord::Migration
  def change
    add_column :partin_take_logs, :from_user_id, :integer
    add_index :partin_take_logs, :from_user_id
  end
end
