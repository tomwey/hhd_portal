class CreateUserCards < ActiveRecord::Migration
  def change
    create_table :user_cards do |t|
      t.string :uniq_id
      t.references :user, index: true, foreign_key: true
      t.references :card, index: true, foreign_key: true
      t.datetime :get_time
      t.datetime :expired_at
      t.integer :_type, null: false
      t.string :discounts, null: false
      t.integer :use_count, default: 0
      t.integer :share_count, default: 0
      t.integer :view_count, default: 0
      t.boolean :opened, default: true
      t.integer :from_user_id

      t.timestamps null: false
    end
    add_index :user_cards, :uniq_id, unique: true
    add_index :user_cards, :from_user_id
  end
end
