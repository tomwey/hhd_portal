class RemoveTotalDepositAndSentDepositFromCards < ActiveRecord::Migration
  def change
    remove_column :cards, :total_deposit, :integer
    remove_column :cards, :sent_deposit, :integer
  end
end
