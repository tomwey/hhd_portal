class AddUseTypeToHongbaos < ActiveRecord::Migration
  def change
    add_column :hongbaos, :use_type, :integer, default: Hongbao::USE_TYPE_BASE
    add_index :hongbaos, :use_type
  end
end
