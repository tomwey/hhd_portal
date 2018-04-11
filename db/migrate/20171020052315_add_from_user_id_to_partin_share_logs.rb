class AddFromUserIdToPartinShareLogs < ActiveRecord::Migration
  def change
    add_column :partin_share_logs, :from_user_id, :integer
    add_index :partin_share_logs, :from_user_id
  end
end
