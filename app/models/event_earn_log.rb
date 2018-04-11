class EventEarnLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  
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
      TradeLog.create!(user_id: user.id, tradeable: event.current_hb, money: money, title: "红包#{event.from_owner_name}" )
    
      # 新增活动发出的红包数量
      event.sent_hb_count += 1;
      event.save!
    
      # 新增活动相关的红包发出的钱
      event.current_hb.add_sent_money!(money) if event.current_hb.present?
    end
    
    # 红包被抢完通知用户
    if event.hb_left_money <= 0.0
      notify_event_owner
    end
    
    # 发红包快被抢完的预警消息
    @left_events_count = Event.joins(:hongbaos).where('events.current_hb_id = hongbaos.uniq_id and hongbaos.total_money != hongbaos.sent_money').valid.count
    # 剩余红包金额
    @left_hongbao_money = Event.joins(:hongbaos).where('events.current_hb_id = hongbaos.uniq_id and hongbaos.total_money != sent_money').valid.to_a.sum(&:hb_left_money).to_f
    
    if @left_events_count == 1 or @left_hongbao_money < 10
      # 最多发三次
      @sent_count ||= Message.joins(:message_template).where(message_templates: { title: '监控预警提醒' }).where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).count
      if @sent_count < 2
        notify_manger
      end
    end
    
  end
  
  def notify_manger
    payload = {
      first: {
        value: "平台红包还剩1个了或所有红包剩余总金额不足10元了。\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "红包库存预警",
        color: "#173177",
      },
      keyword2: {
        value: "#{Time.zone.now.strftime('%Y年%m月%d日 %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "需要尽快去增加红包~",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: [64784012, 90242816]).pluck(:id).to_a
    
    Message.create!(message_template_id: 6, content: payload,link: SiteConfig.wx_app_url, to_users: user_ids)
  end
  
  def notify_event_owner
    count = EventEarnLog.where(event_id: event.id, hb_id: event.current_hb.uniq_id).count
    payload = {
      first: {
        value: "您的红包已经被抢完了！\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{event.title}",
        color: "#173177",
      },
      keyword2: {
        value: "#{count}",
        color: "#173177",
      },
      keyword3: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "现在继续去发红包吧~",
        color: "#173177",
      }
    }.to_json
    
    Message.create!(message_template_id: 5, content: payload, link: SiteConfig.wx_app_url, to_users: [event.ownerable.id])
  end
  
end
