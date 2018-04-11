class CreateQqProfiles < ActiveRecord::Migration
  def change
    create_table :qq_profiles do |t|
      t.integer :user_id
      t.string :openid, null: false, default: ''
      t.string :nickname
      t.string :sex
      t.string :language
      t.string :city
      t.string :province
      t.string :country
      t.string :headimgurl
      t.string :access_token
      t.string :refresh_token

      t.timestamps null: false
    end
    add_index :qq_profiles, :user_id
    add_index :qq_profiles, :openid, unique: true
    add_index :qq_profiles, :access_token
    add_index :qq_profiles, :refresh_token
  end
end
