class CreateWithdraws < ActiveRecord::Migration
  def change
    create_table :withdraws do |t|
      t.string :oid
      t.decimal :money, precision: 16, scale: 2, null: false
      t.decimal :fee, precision: 16, scale: 2, default: 0
      t.string :account_no, null: false
      t.string :account_name
      t.integer :user_id
      t.datetime :payed_at

      t.timestamps null: false
    end
    add_index :withdraws, :user_id
    add_index :withdraws, :oid, unique: true
  end
end
