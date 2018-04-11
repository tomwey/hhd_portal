class CreateRedbagShareEarnLogs < ActiveRecord::Migration
  def change
    create_table :redbag_share_earn_logs do |t|
      t.integer :user_id
      t.integer :from_user_id
      t.integer :redbag_id
      t.string :uniq_id
      t.string :money, precision: 16, scale: 2, null: false, default: 0.0

      t.timestamps null: false
    end
    
    add_index :redbag_share_earn_logs, :uniq_id, unique: true
    add_index :redbag_share_earn_logs, [:from_user_id, :redbag_id, :user_id], unique: true, name: 'from_user_redbag_idx'
    add_index :redbag_share_earn_logs, :user_id
    add_index :redbag_share_earn_logs, :from_user_id
    add_index :redbag_share_earn_logs, :redbag_id
  end
end
