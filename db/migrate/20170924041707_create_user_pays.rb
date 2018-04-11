class CreateUserPays < ActiveRecord::Migration
  def change
    create_table :user_pays do |t|
      t.integer :uniq_id
      t.references :user, index: true, foreign_key: true
      t.decimal :money, precision: 16, scale: 2, null: false
      t.datetime :payed_at

      t.timestamps null: false
    end
    add_index :user_pays, :uniq_id, unique: true
  end
end
