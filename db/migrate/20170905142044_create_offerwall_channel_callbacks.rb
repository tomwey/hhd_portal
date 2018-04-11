class CreateOfferwallChannelCallbacks < ActiveRecord::Migration
  def change
    create_table :offerwall_channel_callbacks do |t|
      t.string :uniq_id
      t.references :offerwall_channel, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :order, null: false, default: ''
      t.string :ad_name, null: false, default: ''
      t.decimal :price, precision: 8, scale: 2
      t.decimal :points,precision: 8, scale: 2
      t.integer :order_time
      t.text :callback_params
      t.string :memo
      
      t.timestamps null: false
    end
    add_index :offerwall_channel_callbacks, :uniq_id, unique: true
    add_index :offerwall_channel_callbacks, :order,   unique: true
  end
end
