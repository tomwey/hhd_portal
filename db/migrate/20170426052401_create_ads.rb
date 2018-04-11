class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.integer :owner_id
      t.integer :oid
      t.string :file, null: false
      t.string :link
      t.integer :duration, null: false
      t.integer :view_count, default: 0
      t.integer :click_count, default: 0
      t.integer :score, default: 0
      t.boolean :opened, default: true

      t.timestamps null: false
    end
    add_index :ads, :owner_id
    add_index :ads, :oid, unique: true
  end
end
