class AddBindAtAndCodeToWechatProfiles < ActiveRecord::Migration
  def change
    add_column :wechat_profiles, :bind_at, :datetime
    add_column :wechat_profiles, :code, :string
  end
end
