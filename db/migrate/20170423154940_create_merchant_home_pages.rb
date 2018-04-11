class CreateMerchantHomePages < ActiveRecord::Migration
  def change
    create_table :merchant_home_pages do |t|
      t.integer :oid
      t.integer :merchant_id
      t.string :title, null: false
      t.text :body,    null: false
      t.string :images, array: true, default: []
      t.boolean :opened, default: true
      t.integer :sort, default: 0

      t.timestamps null: false
    end
    add_index :merchant_home_pages, :oid, unique: true
    add_index :merchant_home_pages, :merchant_id
  end
end
