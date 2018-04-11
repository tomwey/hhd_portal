class AddLikesCountToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :likes_count, :integer, default: 0
  end
end
