class Checkin < ActiveRecord::Base
  belongs_to :redbag
  belongs_to :user
  
  validates :user_id, presence: true
  
  after_create :send_redbag
  def send_redbag
    redbag = Redbag.where(use_type: Redbag::USE_TYPE_CHECKIN).no_complete.order('id desc').first
    if redbag && !user.grabed?(redbag)
      # value = redbag.rand_money
      
      self.redbag_id = redbag.id
      # self.money = value
      
      self.save!
      
      # 写收益日志
      # RedbagEarnLog.create!(user_id: user.id, redbag_id: redbag.id, money: value, ip: ip, location: location)
    end
  end
end
