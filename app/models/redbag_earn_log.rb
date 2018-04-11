class RedbagEarnLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :redbag
  
  validates :user_id, :redbag_id, :money, presence: true
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :change_user_earn_and_update_hb_stats
  def change_user_earn_and_update_hb_stats
    # 只有答对了题目，获得了红包才有下面的处理
    if (money > 0.0)   
      
      # if redbag.is_cash_hb && redbag.wechat_redbag_config
      #   # 发送的是现金红包
      #   RedbagEarnLog.transaction do
      #     # 新增用户的收入
      #     user.earn += money
      #     user.save!
      #
      #     # 生成交易明细
      #     TradeLog.create!(user_id: user.id, tradeable: self, money: money, title: "收到现金红包，来自#{redbag.wechat_redbag_config.send_name}" )
      #
      #     # 更新红包统计
      #     redbag.change_sent_stats!(money) # 在2017-09-03发现了一个问题：执行到一定的时候，没有更新到数据库里面去
      #
      #     # 生成现金红包发送日志
      #     CashRedbagLog.create!(user_id: user.id, redbag_id: redbag.id, money: money)
      #   end
      #
      # else
        #### 非现金红包
        RedbagEarnLog.transaction do
          # 新增用户的收益
          user.add_earn!(money)
    
          # 生成交易明细
          TradeLog.create!(user_id: user.id, tradeable: self, money: money, title: "红包#{redbag.owner_name.blank? ? '' : '来自' + redbag.owner_name }" )
    
          # 更新红包统计
          redbag.change_sent_stats!(money)
          
          # 给用户发卡
          if redbag.card
            redbag.card.send_to_user(user)
          end
          
        end
      # end
      
    end
    
    # 如果红包发完了，通知红包所有者
    redbag.notify_owner_if_sent_done
    
    # 通知平台管理员，所有红包快被抢完了
    notify_backend_manager_if_needed
    
  end
  
  def group_by_date
    created_at.to_date.to_s(:db)
  end
  
  def user_card
    return nil if redbag.card_id.blank?
    
    return UserCard.where(user_id: user.id, card_id: redbag.card_id).order('id desc').first
  end
  
  def notify_backend_manager_if_needed
    # 取平台上还剩的总的红包金额
    @left_moneys = Redbag.not_share.opened.no_complete.select('total_money, sent_money, (total_money - sent_money) as left_money').map { |hb| hb.left_money }.sum.to_f
    
    # 少于2元的时候，发一次提醒消息
    if @left_moneys < 2
      send_redbag_left_money_low(2)
      return
    end
    
    # 少于5元的时候，发一次提醒消息
    if @left_moneys < 5
      send_redbag_left_money_low(5)
      return
    end
    
    # 小于10元的时候，发一次提醒消息
    if @left_moneys < 10
      send_redbag_left_money_low(10)
      return
    end
    
    # 被抢完了的时候，发一次消息
    if @left_moneys <= 0.0
      send_redbag_left_money_low(0)
      return
    end
    
  end
    
  def send_redbag_left_money_low(money)
    msg = money == 0 ? "所有红包已被抢完了" : "平台红包还剩不到#{money}元。"
    @sent_count = Message.joins(:message_template).where(message_templates: { title: '监控预警提醒' }).where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).where('content like ?', '%' + msg + '%').count
    if @sent_count > 0
      return
    end
    
    # message = money == 0 ? '所有红包已被抢完了' : "平台红包还剩不到#{money}元。"
    payload = {
      first: {
        value: "#{msg}\n",
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
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    
    Message.create!(message_template_id: 6, content: payload,link: SiteConfig.wx_app_url, to_users: user_ids)
  end
  
end
