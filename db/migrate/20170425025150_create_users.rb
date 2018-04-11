class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :mobile
      t.string :nickname
      t.string :avatar
      t.string :bio
      t.decimal :balance, precision: 16, scale: 2, default: 0.0
      t.decimal :earn, precision: 16, scale: 2, default: 0.0
      t.string :wx_id
      t.string :wx_avatar
      t.string :private_token
      t.boolean :verified, default: true

      t.timestamps null: false
    end
    add_index :users, :uid, unique: true
    add_index :users, :mobile, unique: true
    add_index :users, :private_token, unique: true
    add_index :users, :wx_id
  end
end
