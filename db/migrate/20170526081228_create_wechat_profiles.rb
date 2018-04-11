class CreateWechatProfiles < ActiveRecord::Migration
  def change
    create_table :wechat_profiles do |t|
      t.string :openid, null: false, default: ''
      t.string :nickname
      t.string :sex
      t.string :language
      t.string :city
      t.string :province
      t.string :country
      t.string :headimgurl
      t.string :subscribe_time
      t.string :unionid
      t.string :access_token
      t.string :refresh_token
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :wechat_profiles, :openid, unique: true
    add_index :wechat_profiles, :access_token
    add_index :wechat_profiles, :refresh_token
    add_index :wechat_profiles, :user_id
  end
end
