class AddOpenCountAndOpenMoneyToRedpackets < ActiveRecord::Migration
  def change
    add_column :red_packets, :open_count, :integer, default: 0
    add_column :red_packets, :open_money, :decimal, precision: 16, scale: 2, default: 0.0
  end
end
