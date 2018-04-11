class AddSharePosterIdToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :share_poster_id, :integer
    add_index :redbags, :share_poster_id
  end
end
