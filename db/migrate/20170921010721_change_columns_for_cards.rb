class ChangeColumnsForCards < ActiveRecord::Migration
  def change
    remove_column :cards, :_type
    remove_column :cards, :discounts
    add_column :cards, :view_count, :integer, default: 0
  end
end
