class AddHbIdToEventEarnLogs < ActiveRecord::Migration
  def change
    add_column :event_earn_logs, :hb_id, :integer
  end
end
