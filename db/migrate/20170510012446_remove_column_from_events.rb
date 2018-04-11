class RemoveColumnFromEvents < ActiveRecord::Migration
  def change
    remove_index :events, :hbid
    remove_column :events, :hbid, :integer
  end
end
