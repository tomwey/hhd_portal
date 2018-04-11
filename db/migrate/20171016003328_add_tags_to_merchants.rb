class AddTagsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :tags, :string, array: true, default: []
  end
end
