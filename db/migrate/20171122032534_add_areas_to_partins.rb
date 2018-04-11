class AddAreasToPartins < ActiveRecord::Migration
  def change
    add_column :partins, :areas, :integer, array: true, default: []
    add_index :partins, :areas
  end
end
