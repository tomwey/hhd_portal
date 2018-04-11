class CreateRedpacks < ActiveRecord::Migration
  def change
    create_table :redpacks do |t|
      t.integer :uniq_id
      t.integer :merchant_id
      t.integer :_type, default: 0 # 0表示拼手气红包 1表示普通红包
      t.integer :total_money, null: false
      # t.integer :min_value
      # t.integer :max_value
      t.integer :sent_money, default: 0
      t.integer :total_count # 红包个数
      t.integer :sent_count, default: 0 # 发出个数
      t.integer :min_value  # 红包最小值
      t.boolean :is_cash, default: false # 是否是发现金红包

      t.timestamps null: false
    end
    add_index :redpacks, :uniq_id, unique: true
    add_index :redpacks, :merchant_id
  end
end
