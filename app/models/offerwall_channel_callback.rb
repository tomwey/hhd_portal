class OfferwallChannelCallback < ActiveRecord::Base
  serialize :callback_params, Hash
  
  belongs_to :offerwall_channel
  belongs_to :user
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :add_user_earn_and_notify
  def add_user_earn_and_notify
    if points > 0.0
      money = self.earn_money
      # 增加用户收入
      user.add_earn!(money)
      
      # 生成交易明细
      TradeLog.create!(user_id: user.id, tradeable: self, money: money, title: "完成联盟下载任务：#{ad_name}")
      
      # 通知用户获得任务收益
      send_notify
    end
  end
  
  def earn_money
    if points > 0.0
      points.to_f / 100.00
    else
      0.0
    end
  end
  
  def send_notify
    payload = {
      first: {
        value: "完成联盟下载任务，获得#{self.earn_money}元\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{'%.2f' % self.earn_money}",
        color: "#173177",
      },
      keyword2: {
        value: "完成任务奖励",
        color: "#173177",
      },
      keyword3: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "\n完成的任务越多，获得的收益也越多哦",
        color: "#173177",
      }
    }.to_json
    
    Message.create!(message_template_id: 9, content: payload, link: SiteConfig.wx_app_url, to_users: [user.id])
  end
  
end
