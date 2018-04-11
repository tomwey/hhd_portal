class CreateNotificationSendLogs < ActiveRecord::Migration
  def change
    create_table :notification_send_logs do |t|
      t.integer :user_id
      t.integer :notification_id
      t.boolean :success

      t.timestamps null: false
    end
    add_index :notification_send_logs, :user_id
    add_index :notification_send_logs, :notification_id
    add_index :notification_send_logs, [:user_id, :notification_id], unique: true
  end
end
