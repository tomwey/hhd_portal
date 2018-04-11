class AddUseTypeToRedpacks < ActiveRecord::Migration
  def change
    add_column :redpacks, :use_type, :integer, default: 0, index: true
  end
end
