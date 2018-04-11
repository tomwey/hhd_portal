class CreateItemPrizes < ActiveRecord::Migration
  def change
    create_table :item_prizes do |t|
      t.references :item, index: true, foreign_key: true
      t.integer :score, null: false
      t.references :prizeable, polymorphic: true, index: true
      t.integer :use_type, default: 0
      t.boolean :can_prize, default: true

      t.timestamps null: false
    end
  end
end
