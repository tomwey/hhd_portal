class UserRedpack < ActiveRecord::Base
  belongs_to :user
  belongs_to :redpack
  
  after_create :change_user_state
  def change_user_state
    if (redpack && money && money > 0)   
      
      if redpack.is_cash
        # 现金红包
        UserRedpack.transaction do
          # 新增用户的收益
          user.earn += money / 100.0
          user.save!
    
          # 生成交易明细
          TradeLog.create!(user_id: user.id, 
                           tradeable: self, 
                           money: money / 100.0, 
                           title: "收到现金红包，来自#{redpack.merchant.try(:name)}" )
    
          # 更新红包统计
          redpack.change_sent_stats!(money)
          
          # 生成现金红包发送记录
          RedpackSendLog.create!(money: money, user: user, redpack: redpack)
          
        end
      else
        # 非现金红包
        UserRedpack.transaction do
          # 新增用户的收益
          user.add_earn!(money / 100.0)
    
          # 生成交易明细
          TradeLog.create!(user_id: user.id, 
                           tradeable: self, 
                           money: money / 100.0, 
                           title: "红包#{redpack.merchant.blank? ? '' : '来自' + redpack.merchant.name }" )
    
          # 更新红包统计
          redpack.change_sent_stats!(money)
        end
        
      end
      
      # 发消息给分享人，获得了收益
      if redpack.is_share_redpack?
        # send_message_to_share_man
      end
      
    end
  end
  
  def format_name
    "#{(money || 0) / 100.0}元"
  end
  
  def send_message_to_share_man
    payload = {
      first: {
        value: "亲！这是给你的分享活动奖励！\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{'%.2f' % (self.money / 100.0 )}",
        color: "#173177",
      },
      keyword2: {
        value: "分享活动奖励",
        color: "#173177",
      },
      keyword3: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "\n分享多多，奖励多多！",
        color: "#173177",
      }
    }.to_json
    
    Message.create!(message_template_id: 9, content: payload, link: SiteConfig.wx_app_url, to_users: [user.id])
  end
  
end
