class CreateRedbagPrizes < ActiveRecord::Migration
  def change
    create_table :redbag_prizes do |t|
      t.string  :name, null: false, default: ''
      t.integer :quantity
      t.integer :sent_count, default: 0
      t.integer :score
      t.integer :redbag_id, null: false

      t.timestamps null: false
    end
    add_index :redbag_prizes, :redbag_id
  end
end
