class AddEventIdToCheckinRules < ActiveRecord::Migration
  def change
    add_column :checkin_rules, :event_id, :integer
    add_index :checkin_rules, :event_id
  end
end
