class CreateUserRedPackets < ActiveRecord::Migration
  def change
    create_table :user_red_packets do |t|
      t.string :oid
      t.integer :user_id, null: false
      t.integer :hb_id,   null: false
      t.decimal :money, precision: 16, scale: 2
      t.string :grabed_ip, null: false
      t.string :opened_ip, null: false
      t.datetime :grabed_at
      t.datetime :opened_at

      t.timestamps null: false
    end
    add_index :user_red_packets, :oid, unique: true
    add_index :user_red_packets, :user_id
    add_index :user_red_packets, :hb_id
    add_index :user_red_packets, [:user_id, :hb_id], unique: true
  end
end
