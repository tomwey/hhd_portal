class AddUnsubscribeTimeToWechatProfiles < ActiveRecord::Migration
  def change
    add_column :wechat_profiles, :unsubscribe_time, :datetime
  end
end
