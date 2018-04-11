class RemoveTableMerchants < ActiveRecord::Migration
  def change
    drop_table :merchants
  end
end
