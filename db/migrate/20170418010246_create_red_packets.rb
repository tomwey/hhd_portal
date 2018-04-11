class CreateRedPackets < ActiveRecord::Migration
  def change
    create_table :red_packets do |t|
      t.integer :oid
      t.string :title, null: false
      t.string :image
      t.decimal :money, precision: 16, scale: 2, null: false
      t.integer :quantity, null: false
      t.datetime :expired_at
      t.integer :owner_id
      t.string :memo
      t.st_point :location, geographic: true
      t.integer :_type, default: 0 # 0 表示随机红包，1 表示固定红包
      t.decimal :min_value, precision: 16, scale: 2
      t.decimal :max_value, precision: 16, scale: 2
      t.integer :sort, default: 0
      t.boolean :opened, default: true 
      
      t.timestamps null: false
    end
    add_index :red_packets, :oid, unique: true
    add_index :red_packets, :owner_id
    add_index :red_packets, :location, using: :gist
  end
end
