class CreateCashRedbagLogs < ActiveRecord::Migration
  def change
    create_table :cash_redbag_logs do |t|
      t.string :uniq_id
      t.references :user, index: true, foreign_key: true
      t.references :redbag, index: true, foreign_key: true
      t.decimal :money, precision: 16, scale: 2, null: false
      t.datetime :sent_at
      t.string :sent_error

      t.timestamps null: false
    end
    add_index :cash_redbag_logs, :uniq_id, unique: true
  end
end
