class RemoveColumnSenderHbIdSharePosters < ActiveRecord::Migration
  def change
    remove_index :share_posters, :sender_hb_id
    remove_column :share_posters, :sender_hb_id
  end
end
