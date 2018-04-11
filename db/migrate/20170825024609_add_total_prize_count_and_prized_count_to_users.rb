class AddTotalPrizeCountAndPrizedCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_prize_count, :integer, default: 5
    add_column :users, :prized_count, :integer, default: 0
  end
end
