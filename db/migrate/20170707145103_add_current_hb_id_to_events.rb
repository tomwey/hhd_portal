class AddCurrentHbIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :current_hb_id, :integer
  end
end
