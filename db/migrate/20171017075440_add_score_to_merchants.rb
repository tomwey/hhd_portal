class AddScoreToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :score, :integer, default: 0
  end
end
