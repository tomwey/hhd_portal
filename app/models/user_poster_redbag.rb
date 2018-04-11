class UserPosterRedbag < ActiveRecord::Base
  belongs_to :user
  belongs_to :redbag
  belongs_to :share_poster
  
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
    @ticket ||= Wechat::Base.fetch_qrcode_ticket("uspr:#{self.uniq_id}", false)
  end
  
  def share_poster_image
    return '' if redbag_id.blank? or share_poster_id.blank?
    
    redbag_text = "识别二维码抢#{redbag.total_money}元红包"
    
    code = self.uniq_id.to_s
    nonce = Time.zone.now.to_i.to_s
    sign = Digest::MD5.hexdigest(code + nonce + SiteConfig.web_access_key)
    
    qrcode_image_url = "#{SiteConfig.app_server}/wx/share_poster_qrcode?code=#{code}&i=#{nonce}&ak=#{sign}"
    
    # puts '二维码地址：' + qrcode_image_url
    
    url = share_poster.share_image(qrcode_image_url, redbag_text)
    # puts url
    
    url 
  end
  
  def commit_redbag_for(for_user, ip)
    return "操作失败，红包不存在" if redbag_id.blank?
    
    return "操作失败，红包还未上架" if not redbag.opened
    
    if redbag.started_at && redbag.started_at > Time.zone.now
      return "操作失败，红包还未开抢"
    end
    
    if redbag.left_money <= 0
      return "您下手太慢了，红包已经被抢完了！"
    end
    
    # 检查用户是否已经抢过
    if for_user.grabed?(redbag)
      return "您已经领取了该活动红包，不能重复参与"
    end
    
    # 发红包
    money = redbag.random_money
    if money <= 0.0
      return "您下手太慢了，红包已经被抢完了！"
    end
    
    # 发红包，记录日志
    earn_log = RedbagEarnLog.create!(user_id: for_user.id, redbag_id: redbag.id, money: money, ip: ip, location: nil)
    
    # TODO: 如果有是通过分享获取的红包，并且该活动有分享红包，那么给分享人发一个分享红包
    if redbag.share_hb
      from_user = user
      if from_user && from_user.verified && redbag.share_hb.total_money > redbag.share_hb.sent_money
        # 给分享人发分享红包
        if RedbagShareEarnLog.where(from_user_id: for_user.id, 
                                    redbag_id: redbag.share_hb.id, 
                                    user_id: from_user.id).count == 0
          share_money = redbag.share_hb.random_money
          if share_money > 0.0
            RedbagShareEarnLog.create!(from_user_id: for_user.id, # 被分享人id
                                       redbag_id: redbag.share_hb.id, 
                                       user_id: from_user.id, # 分享人id
                                       money: share_money)
          end # end send money
        end # 还没有得到过红包
      end # 可以发分享红包
    end # 如果设置了分享红包
    
    return "恭喜您抢到#{money}元，已存入惠互动钱包。\n点击下方“来抢红包”继续赚钱吧！"
    
  end
  
end
