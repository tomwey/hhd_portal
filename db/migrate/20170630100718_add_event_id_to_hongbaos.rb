class AddEventIdToHongbaos < ActiveRecord::Migration
  def change
    add_column :hongbaos, :event_id, :integer
    add_index :hongbaos, :event_id
  end
end
