class WechatProfile < ActiveRecord::Base
  belongs_to :user
  
  def group_by_subscribe_date
    Time.at(subscribe_time.to_i).to_date.to_s(:db)
  end
  
  def group_by_unsubscribe_date
    unsubscribe_time.to_date.to_s(:db)
  end
  
  def generate_code!
    self.code = rand.to_s[2..7]
    self.save!
  end
  
end
