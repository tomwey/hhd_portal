class CreateRedpackSendLogs < ActiveRecord::Migration
  def change
    create_table :redpack_send_logs do |t|
      t.string :uniq_id
      t.references :redpack, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :money, null: false
      t.datetime :sent_at
      t.string :sent_error

      t.timestamps null: false
    end
    add_index :redpack_send_logs, :uniq_id, unique: true
  end
end
