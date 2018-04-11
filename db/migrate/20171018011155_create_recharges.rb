class CreateRecharges < ActiveRecord::Migration
  def change
    create_table :recharges do |t|
      t.string :uniq_id
      t.references :merchant, index: true, foreign_key: true, null: false
      t.integer :money, null: false, default: ''
      t.string :ip
      t.datetime :payed_at

      t.timestamps null: false
    end
    add_index :recharges, :uniq_id, unique: true
  end
end
