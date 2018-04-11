class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :money, null: false, default: ''
      t.integer :user_id, null: false
      t.string :ip
      t.string :uniq_id
      t.datetime :payed_at

      t.timestamps null: false
    end
    add_index :charges, :user_id
    add_index :charges, :uniq_id, unique: true
  end
end
