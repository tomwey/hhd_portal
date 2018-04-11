class UserPay < ActiveRecord::Base
  belongs_to :user
  # belongs_to :merchant
  
  validates :user_id, :money, presence: true
  
  scope :payed, -> { where.not(payed_at: nil) }
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..9]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def qrcode_ticket
    @ticket ||= Wechat::Base.fetch_qrcode_ticket("up:#{self.uniq_id}", false)
  end
  
  def payed?
    self.payed_at.present?
  end
  
  def verify_consume_for(to_user)
    if not merchant.supports_user_pay
      YunbaSendJob.perform_later(self.uniq_id, "操作失败，商家未开通余额抵扣功能")
      return "操作失败，您还未开通余额抵扣功能。"
    end
    
    if self.money > self.user.balance
      YunbaSendJob.perform_later(self.uniq_id, "操作失败，余额不足")
      return "操作失败，余额不足"
    end
    
    if self.payed?
      YunbaSendJob.perform_later(self.uniq_id, "操作失败，不能重复抵扣")
      return "操作失败，不能重复抵扣"
    end
    
    # 修改余额
    User.transaction do
      self.user.balance -= self.money
      self.user.save!
      
      self.payed_at = Time.zone.now
      # self.merchant_id = merchant.id
      self.to_user_id = to_user.id
      self.save!
      
      # TODO: 未完成的功能
      # 生成交易明细
      # TradeLog.create!(user_id: self.user.id,
      #                  tradeable: self,
      #                  money: money,
      #                  title: "向商家[#{merchant.name}]余额抵扣#{money}元" )
      #
      # # 发现金红包给商家
      # CashRedbagSendLog.create!(to_user_id: self.to_user_id,
      #                           send_name: '惠互动',
      #                           money: money,
      #                           wishing:'余额抵扣',
      #                           act_name: '消费',
      #                           remark: '无',
      #                           scene_id: 'PRODUCT_4')
    end

    YunbaSendJob.perform_later(self.uniq_id, "操作成功，成功抵扣#{money}元")
    
    return "操作成功，成功抵扣#{money}元"
  end
  
end
