class UserCard < ActiveRecord::Base
  belongs_to :user
  belongs_to :card
  
  delegate :title, to: :card, prefix: false, allow_nil: true
  delegate :image, to: :card, prefix: false, allow_nil: true
  delegate :body, to: :card, prefix: false, allow_nil: true
  
  scope :opened, -> { where(opened: true) }
  scope :not_used, -> { where(used_at: nil) }
  scope :not_expired, -> { where('expired_at is null or expired_at > ?', Time.zone.now) }
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..9])
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :add_sent_count_for_card
  def add_sent_count_for_card
    card.add_sent_count if card.present?
    
    if card && card.price > 0 && user
      user.balance -= card.price / 100.0
      user.save!
      
      # 生成交易明细
      TradeLog.create!(user_id: user.id, 
                       tradeable: self, 
                       money: card.price / 100.0, 
                       title: "购买优惠卡:#{card.title}" )
                    
    end
  end
  
  def add_view_count
    self.class.increment_counter(:view_count, self.id)
    self.card.add_view_count
  end
  
  def add_share_count
    self.class.increment_counter(:share_count, self.id)
    self.card.add_share_count
  end
  
  def add_use_count
    self.class.increment_counter(:use_count, self.id)
  end
  
  def expired?
    (self.expired_at && self.expired_at < Time.zone.now.beginning_of_day)
  end
  
  def body_url
    "#{SiteConfig.app_server}/wx/user_card_qrcode"
  end
  
  def format_name
    self.title
  end
  
  def used?
    self.used_at.present?
  end
  
  def use_limited?
    !opened or (card.limit_use_times && card.limit_use_times <= use_count)
  end
  
  def use_card
    # TODO
  end
  
  def active_qrcode
    "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{self.qrcode_ticket}"
  end
  
  def qrcode_ticket
    @ticket ||= Wechat::Base.fetch_qrcode_ticket("uc:#{self.uniq_id}", false)
  end
  
  def verify_consume_for(merchant)
    
    if merchant != self.card.ownerable
      msg = "操作失败，不正确的商家"
      YunbaSendJob.perform_later(self.uniq_id, msg)
      return msg
    end
    
    if self.expired?
      msg = "操作失败，卡已经过期"
      YunbaSendJob.perform_later(self.uniq_id, msg)
      return msg
    end
    
    if self.used?
      msg = "操作失败，卡已经使用过"
      YunbaSendJob.perform_later(self.uniq_id, msg)
      return msg
    end
    
    # 激活
    self.used_at = Time.zone.now
    self.save!
    
    self.card.add_use_count
    
    msg = "操作成功，卡已经验证通过"
    YunbaSendJob.perform_later(self.uniq_id, msg)
    return msg
    
  end
  
end
