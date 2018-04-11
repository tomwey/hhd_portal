class AddTotalDepositAndSentDepositToCards < ActiveRecord::Migration
  def change
    add_column :cards, :total_deposit, :integer
    add_column :cards, :sent_deposit, :integer, default: 0
  end
end
