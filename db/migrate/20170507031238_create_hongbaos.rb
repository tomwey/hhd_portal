class CreateHongbaos < ActiveRecord::Migration
  def change
    create_table :hongbaos do |t|
      t.integer :uniq_id
      t.decimal :total_money, precision: 16, scale: 2, null: false
      t.integer :_type, default: 0 # 0 表示随机红包，1 表示固定红包
      t.decimal :min_value, precision: 16, scale: 2, null: false
      t.decimal :max_value, precision: 16, scale: 2, null: false
      t.decimal :sent_money, default: 0

      t.timestamps null: false
    end
    add_index :hongbaos, :uniq_id, unique: true
  end
end
