class EventShareEarnLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  belongs_to :for_user, class_name: 'User', foreign_key: 'for_user_id'
  
  validates :user_id, :event_id, :money, presence: true
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :change_user_earn_and_update_event_stats
  def change_user_earn_and_update_event_stats
    # 只有答对了题目，获得了红包才有下面的处理
    if (money > 0.0)    
      # 新增用户的收益
      user.add_earn!(money)
    
      # 生成交易明细
      TradeLog.create!(user_id: user.id, tradeable: event.share_hb, money: money, title: "分享红包-来自#{for_user.format_nickname}参与活动[#{event.title}]" )
    
      # 新增活动发出的红包数量
      # event.sent_hb_count += 1;
      # event.save!
    
      # 新增活动分享红包发出的钱
      event.share_hb.add_sent_money!(money) if event.share_hb.present?
      
      send_message
    end
    
  end
  
  def send_message
    payload = {
      first: {
        value: "亲！这是给你的分享红包广告奖励！\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{'%.2f' % self.money}",
        color: "#173177",
      },
      keyword2: {
        value: "分享红包广告奖励",
        color: "#173177",
      },
      keyword3: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "\n红包广告分享多多，奖励多多！",
        color: "#173177",
      }
    }.to_json
    
    Message.create!(message_template_id: 9, content: payload, link: SiteConfig.wx_app_url, to_users: [user.id])
  end
  
end
