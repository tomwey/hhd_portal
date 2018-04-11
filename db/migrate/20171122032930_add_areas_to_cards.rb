class AddAreasToCards < ActiveRecord::Migration
  def change
    add_column :cards, :areas, :integer, array: true, default: []
    add_index :cards, :areas
  end
end
