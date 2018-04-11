class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :merchant_id
      t.string :title, null: false, default: ''
      t.string :content, null: false, default: ''
      t.integer :badge
      # t.integer :to_users, array: true, default: []
      t.integer :_type, default: 0 # 0 表示通知打开不用处理 1 表示收到通知，打开显示一个网页 2 表示收到红包提醒通知 3 表示收到优惠券通知
      t.string :link # 值可能为空，也可以是一个url地址, 可能是一个红包的ID，或者一个优惠券ID

      t.timestamps null: false
    end
    add_index :notifications, :merchant_id
  end
end
