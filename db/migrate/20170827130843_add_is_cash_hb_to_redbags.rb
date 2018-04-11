class AddIsCashHbToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :is_cash_hb, :boolean, default: false
  end
end
