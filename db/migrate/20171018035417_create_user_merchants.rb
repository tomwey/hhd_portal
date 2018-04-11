class CreateUserMerchants < ActiveRecord::Migration
  def change
    create_table :user_merchants do |t|
      t.references :user, index: true, null: false
      t.references :merchant, index: true, null: false

      t.timestamps null: false
    end
    add_index :user_merchants, [:user_id, :merchant_id], unique: true
  end
end
