class UserChannelLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_channel
  
  after_create :change_users_count
  def change_users_count
    user_channel.users_count += 1
    user_channel.save!
  end
  
end
