class ChangeColumnForRedbagShareEarnLogs < ActiveRecord::Migration
  def change
    remove_column :redbag_share_earn_logs, :money
    add_column :redbag_share_earn_logs, :money, :decimal, precision: 16, scale: 2
  end
end
