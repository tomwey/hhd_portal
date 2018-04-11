class CreateWechatAuthCodes < ActiveRecord::Migration
  def change
    create_table :wechat_auth_codes do |t|
      t.string :wx_id, null: false, default: ''
      t.string :code
      t.datetime :actived_at

      t.timestamps null: false
    end
    add_index :wechat_auth_codes, :wx_id
    add_index :wechat_auth_codes, :code
  end
end
