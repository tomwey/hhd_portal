class AddHitsToMerchantHomePages < ActiveRecord::Migration
  def change
    add_column :merchant_home_pages, :hits, :integer, default: 0
  end
end
