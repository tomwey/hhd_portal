class CreateCashRedbagSendLogs < ActiveRecord::Migration
  def change
    create_table :cash_redbag_send_logs do |t|
      t.string :uniq_id
      t.string :send_name, null: false
      t.integer :to_user_id, null: false
      t.decimal :money, precision: 16, scale: 2, null: false, default: 0.0
      t.string :wishing, null: false
      t.string :act_name, null: false
      t.string :remark,   null: false, default: ''
      t.string :scene_id, null: false, default: ''
      t.datetime :sent_at
      t.string :sent_error

      t.timestamps null: false
    end
    add_index :cash_redbag_send_logs, :uniq_id, unique: true
    add_index :cash_redbag_send_logs, :to_user_id
  end
end
