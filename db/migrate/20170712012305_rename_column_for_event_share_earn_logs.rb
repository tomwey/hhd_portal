class RenameColumnForEventShareEarnLogs < ActiveRecord::Migration
  def change
    rename_column :event_share_earn_logs, :from_user_id, :for_user_id
  end
end
