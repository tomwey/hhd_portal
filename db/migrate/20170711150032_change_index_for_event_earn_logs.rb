class ChangeIndexForEventEarnLogs < ActiveRecord::Migration
  def change
    remove_index :event_earn_logs, [:user_id, :event_id]
    add_index :event_earn_logs, [:user_id, :event_id, :hb_id], unique: true, name: 'user_event_hb_idx'
  end
end
