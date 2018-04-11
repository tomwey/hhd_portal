class AddShareHbIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :share_hb_id, :integer
    add_index :events, :share_hb_id
  end
end
