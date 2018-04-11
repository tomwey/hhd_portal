class AddUniqIdToTradeLogs < ActiveRecord::Migration
  def change
    add_column :trade_logs, :uniq_id, :string
    add_index :trade_logs, :uniq_id, unique: true
  end
end
