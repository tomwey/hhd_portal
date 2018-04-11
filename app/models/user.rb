class User < ActiveRecord::Base
  
  # has_many :follows, dependent: :destroy
  # has_many :followed_merchants, through: :follows, source: :merchant
  has_many :events, as: :ownerable
  has_many :redbags, as: :ownerable
  has_many :lucky_draws, as: :ownerable
  
  has_many :event_earn_logs
  has_many :redbag_earn_logs
  has_many :redbag_share_earn_logs
  has_many :trade_logs
  
  has_many :partin_take_logs
  
  # has_and_belongs_to_many :merchants
  has_many :user_merchants
  has_many :merchants, through: :user_merchants
  
  has_many :lucky_draw_prize_logs
  
  has_many :redbag_share_logs
  has_many :share_redbags, through: :redbag_share_logs, source: :redbag
  
  has_many :user_sessions, dependent: :destroy
  
  has_one :wechat_profile, dependent: :destroy
  has_one :qq_profile, dependent: :destroy
  
  mount_uploader :avatar, AvatarUploader
  
  scope :followed, -> { includes(:wechat_profile).where.not(wechat_profiles: { subscribe_time: nil }).where(wechat_profiles: { unsubscribe_time: nil }) }
  scope :unfollowed, -> { includes(:wechat_profile).where.not(wechat_profiles: { unsubscribe_time: nil }) }
  
  before_create :generate_uid_and_private_token
  def generate_uid_and_private_token
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uid = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uid => uid)
    self.private_token = SecureRandom.uuid.gsub('-', '')
  end
  
  def hack_mobile
    return "" if self.mobile.blank?
    hack_mobile = String.new(self.mobile)
    hack_mobile[3..6] = "****"
    hack_mobile
  end
    
  def wx_id
    self[:wx_id] || wechat_profile.try(:openid) || ''
  end
  
  def bind_wx
    wechat_profile.present?
  end
  
  def format_nickname
    text = wechat_profile.try(:nickname) || hack_mobile || self.nickname
    if text.blank?
      text = "ID: #{self.uid}"
    end
    text
  end
  
  def today_earn
    @earn ||= redbag_earn_logs.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:money)
    @earn2 ||= redbag_share_earn_logs.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:money)
    @earn + @earn2
  end
  
  def online_time
    us = user_sessions.order('id desc').first
    if us.end_time.blank? or us.begin_time.blank?
      return '--'
    end
    
    times = (us.end_time - us.begin_time).to_i
    if times < 60
      "#{times}秒"
    else
      "#{times / 60}分钟"
    end
  end
  
  def add_earn!(money)
    if money > 0
      self.balance += money
      self.earn    += money
      self.save!
    end
  end
  
  def can_prize?
    (self.total_prize_count > self.prized_count)
  end
  
  def add_prized_count!
    self.class.increment_counter(:prized_count, self.id)
  end
  
  def prized?(prizeable)
    return false if prizeable.blank?
    
    LuckyDrawPrizeLog.where(user_id: self.id, lucky_draw_id: prizeable.id).count > 0
  end
  
  def format_avatar_url
    if avatar.present?
      avatar.url(:large)
    else
      wechat_profile.try(:headimgurl) || ''
    end
  end
  
  def real_avatar_url
    if avatar.present?
      avatar.url(:large)
    # elsif wx_avatar
    #   wx_avatar
    else
      @headimgurl_ = wechat_profile.try(:headimgurl)
      if @headimgurl_.blank? || @headimgurl_ == '/0'
        "http://hb-assets.small-best.com/uploads/attachment/data/207/3d284f5a-924d-476e-8375-33c21c578817.png?e=1814843729&token=TL7vgIdADfCg9dJGncUGqvj51t0JfO8IORBBO9JX:Y9T3nKgM6xNiBeSkUtvixSuoe94="
      else
         @headimgurl_
      end
    end
  end
  
  def add_use_sessions_count
    self.class.increment_counter(:use_sessions_count, self.id)
  end
  
  def current_location
    loc = WechatLocation.where(user_id: self.id).order('id desc').first
    if loc.blank?
      ""
    else
      "#{loc.lat},#{loc.lng}"
    end
  end
  
  def add_user_location(lat, lng, precision)
    WechatLocation.where(lat: lat, lng: lng, precision: precision, user_id: self.id).first_or_create
  end
  
  def grabed?(hb)
    return false if hb.blank?
    
    RedbagEarnLog.where(user_id: self.id, redbag_id: hb.id).count > 0
  end
  
  def taked?(partin)
    return false if partin.blank?
    
    PartinTakeLog.where(user_id: self.id, partin_id: partin.id).count > 0
  end
  
  def grabed_item?(item)
    return false if item.blank?
    
    ItemWinLog.where(user:self, item:item).count > 0
  end
  
  def taked_card?(card)
    return false if card.blank?
    UserCard.where(user: self, card: card).count > 0
  end
  
  def liked?(likeable)
    return true if likeable.blank?
    
    Like.where(user_id: self.id, likeable: likeable).count > 0
  end
  
  def subscribed?
    return false if wechat_profile.blank?
    
    if wechat_profile.subscribe_time.blank?
      return false
    end
    
    if wechat_profile.unsubscribe_time.present?
      return false
    end
    
    return true
  end
  
  def block!
    self.verified = false
    self.save!
  end
  
  def unblock!
    self.verified = true
    self.save!
  end
  
  def self.from_wechat_auth(result)
    auth = WechatProfile.find_by(openid: result['openid'])
    if auth.blank?
      # 开始获取用户基本信息
      user_info = RestClient.get "https://api.weixin.qq.com/sns/userinfo", 
                     { :params => { 
                                    :access_token => result['access_token'],
                                    :openid       => result['openid'],
                                    :lang         => "zh_CN",
                                  } 
                     }
      user_info_result = JSON.parse(user_info)
      
      user = User.new
      profile = WechatProfile.new(openid: result['openid'],
                                  nickname: user_info_result['nickname'],
                                  sex: user_info_result['sex'],
                                  language: user_info_result['language'],
                                  city: user_info_result['city'],
                                  province: user_info_result['province'],
                                  country: user_info_result['country'],
                                  headimgurl: user_info_result['headimgurl'],
                                  #subscribe_time: result['subscribe_time'],
                                  unionid: user_info_result['unionid'],
                                  access_token: result['access_token'],
                                  refresh_token: result['refresh_token'])
      user.wechat_profile = profile
      user.save!
    else
      auth.access_token = result['access_token']
      auth.refresh_token = result['refresh_token']
      auth.save!
      user = auth.user
    end
    
    user
    
  end
  
  def group_by_date
    created_at.to_date.to_s(:db)
  end
  
  def withdrawed?
    Withdraw.where(user_id: self.id, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count > 0
  end
  
  # def followed?(followable)
  #   return false if followable.blank?
  #   Follow.where(user_id: self.id, merchant_id: followable.id).count > 0
  # end
  # 
  # def follow!(followable)
  #   return false if followable.blank?
  #   Follow.create!(user_id: self.id, merchant_id: followable.id)
  # end
  # 
  # def unfollow!(followable)
  #   return false if followable.blank?
  #   follow = Follow.where(user_id: self.id, merchant_id: followable.id).first
  #   follow.destroy
  # end
  
end
