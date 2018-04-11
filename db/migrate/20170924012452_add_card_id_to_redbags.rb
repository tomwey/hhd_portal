class AddCardIdToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :card_id, :integer
    add_index :redbags, :card_id
  end
end
