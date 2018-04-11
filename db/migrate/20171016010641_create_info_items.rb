class CreateInfoItems < ActiveRecord::Migration
  def change
    create_table :info_items do |t|
      t.integer :uniq_id
      t.string :title, null: false, default: ''
      t.string :image
      t.text :body, null: false, default: ''
      t.integer :merchant_id, null: false

      t.timestamps null: false
    end
    add_index :info_items, :merchant_id
    add_index :info_items, :uniq_id, unique: true
  end
end
