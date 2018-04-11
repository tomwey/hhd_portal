class AddIndexToRedbags < ActiveRecord::Migration
  def change
    add_index :redbags, :use_type
  end
end
