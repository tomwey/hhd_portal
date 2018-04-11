class Withdraw < ActiveRecord::Base
  belongs_to :user
  
  validates :user_id, :money, :account_no, presence: true
  
  before_create :generate_oid
  def generate_oid
    begin
      self.oid = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:oid => oid)
  end
  
  after_create :add_trade_log
  def add_trade_log
    TradeLog.create!(tradeable: self, user_id: self.user_id, money: self.money, title: "#{note || '提现'}#{'%.2f' % self.money}元")
    
    
    # if self.money < 10
      # 自动提现
      WithdrawJob.set(wait: 1.seconds).perform_later(self.id)
    # else
      # 发送消息
      # send_message
    # end
  end
  
  def confirm_pay!
    
    # {"return_code"=>"SUCCESS", "return_msg"=>"", "mchid"=>"1482457452", "nonce_str"=>"7794830b48b7773c48b1660244ddf704", "result_code"=>"SUCCESS", "partner_trade_no"=>"171030101147253", "payment_no"=>"1000018301201710300947831627", "payment_time"=>"2017-10-30 10:13:14"}
    
    return do_pay
  end
  
  def do_pay
    # Wechat::Pay.pay(billno, openid, user_name, money)
    if account_no == account_name
      # 微信提现
      result = Wechat::Pay.pay(self.oid, user.wechat_profile.try(:openid), account_name, (money - fee))
      puts result
      if result['return_code'] == 'SUCCESS' && result['result_code'] == 'SUCCESS'
        self.payed_at = Time.zone.now#DateTime.parse(result['payment_time'])
        self.save!
        
        # 通知管理员
        notify_backend_manager('')
        
        return ''
      else
        
        # 通知管理员
        notify_backend_manager(result['return_msg'])
        
        return result['return_msg']
      end
    else
      code,msg = Alipay::Pay.pay(self.oid, account_no, account_name, money - fee)
      if code == 0
        self.payed_at = Time.zone.now
        self.save!
        
        # 通知管理员
        notify_backend_manager('')
        
        return ''
      else
        
        # 通知管理员
        notify_backend_manager(msg)
        
        return msg
      end
    end
    
  end
  
  def notify_backend_manager(result)
    sp = account_no == account_name ? '微信' : '支付宝'
    msg = result.blank? ? "用户[#{user.format_nickname}]成功提现#{self.money}元到#{sp}" : "[#{sp}]提现失败，#{result}"
    payload = {
      first: {
        value: "#{msg}\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "提现操作提醒",
        color: "#173177",
      },
      keyword2: {
        value: "#{Time.zone.now.strftime('%Y年%m月%d日 %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "请留意账户余额变化",
        color: "#173177",
      }
    }.to_json
    
    user = User.find_by(uid: 64784012)
    if user
      Message.create!(message_template_id: 6, content: payload,link: '', to_users: [user.id])
    end
    
  end
  
  def send_message
    payload = {
      first: {
        value: "您好，提现申请已经收到，大约1-2天会到账\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{user.format_nickname}",
        color: "#173177",
      },
      keyword2: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      },
      keyword3: {
        value: "#{money == 0.0 ? '0.00' : '%.2f' % money}元",
        color: "#173177",
      },
      keyword4: {
        value: "#{account_no == account_name ? '微信' : '支付宝'}",
        color: "#173177",
      },
      remark: {
        value: "感谢您的使用！",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    if not user_ids.include?(user.id)
      user_ids << user.id
    end
    Message.create!(message_template_id: 7, content: payload,link: SiteConfig.wx_app_url, to_users: user_ids)
  end
end
