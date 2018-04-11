class Charge < ActiveRecord::Base
  belongs_to :user
  validates :money, :user_id, presence: true
  validates :money, numericality: { only_integer: true, greater_than: 0 }
  
  before_create :generate_uniq_id
  
  scope :payed, -> { where.not(payed_at: nil) }
  
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def not_payed?
    self.payed_at.blank?
  end
  
  def pay!
    self.payed_at = Time.zone.now
    self.save!
    
    TradeLog.create!(tradeable: self, user_id: self.user_id, money: self.money, title: '充值')
    
    # 更新用户的余额
    if user.present?
      user.balance += self.money
      user.save!
    end
    
    # 发送消息
    payload = {
      first: {
        value: "账号充值成功！\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{self.money}元",
        color: "#173177",
      },
      keyword2: {
        value: "#{self.created_at.strftime('%Y年%m月%d日 %H:%M')}",
        color: "#173177",
      },
      keyword3: {
        value: "#{user.balance == 0.0 ? '0.00' : '%.2f' % user.balance}元",
        color: "#173177",
      },
      remark: {
        value: "感谢您对惠互动平台的支持！",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    if not user_ids.include?(user.id)
      user_ids << user.id
    end
    
    Message.create!(message_template_id: 2, content: payload, link: SiteConfig.wx_app_url, to_users: user_ids)
    
  end
  
end
