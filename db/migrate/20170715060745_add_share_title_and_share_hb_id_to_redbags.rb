class AddShareTitleAndShareHbIdToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :share_title, :string
    add_column :redbags, :share_hb_id, :integer, index: true
  end
end
