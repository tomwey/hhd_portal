class WechatAuthCode < ActiveRecord::Base
  validates :wx_id, presence: true
  
  before_create :generate_code
  def generate_code
    self.code = rand.to_s[2..7]
  end
  
  def actived?
    !self.actived_at.blank?
  end
end
