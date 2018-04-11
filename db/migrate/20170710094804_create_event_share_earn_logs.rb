class CreateEventShareEarnLogs < ActiveRecord::Migration
  def change
    create_table :event_share_earn_logs do |t|
      t.integer :user_id
      t.integer :from_user_id
      t.integer :event_id
      t.integer :hb_id
      t.string :uniq_id
      t.decimal :money, precision: 16, scale: 2, null: false, default: 0.0

      t.timestamps null: false
    end
    add_index :event_share_earn_logs, :uniq_id, unique: true
    add_index :event_share_earn_logs, [:from_user_id, :event_id, :hb_id], unique: true, name: 'from_user_event_hb_idx'
    add_index :event_share_earn_logs, :user_id
  end
end
