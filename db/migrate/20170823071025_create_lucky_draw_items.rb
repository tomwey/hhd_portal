class CreateLuckyDrawItems < ActiveRecord::Migration
  def change
    create_table :lucky_draw_items do |t|
      t.integer :uniq_id
      t.string :name, null: false, default: ''
      t.integer :angle, null: false
      t.integer :quantity, null: false
      t.integer :sent_count, default: 0
      t.references :lucky_draw, index: true, foreign_key: true
      t.boolean :is_virtual_goods, default: true
      t.string :description

      t.timestamps null: false
    end
    add_index :lucky_draw_items, :uniq_id, unique: true
  end
end
