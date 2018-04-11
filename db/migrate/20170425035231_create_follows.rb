class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :user_id, null: false
      t.integer :merchant_id, null: false

      t.timestamps null: false
    end
    add_index :follows, :user_id
    add_index :follows, :merchant_id
    add_index :follows, [:user_id, :merchant_id], unique: true
  end
end
