class Redbag < ActiveRecord::Base
  belongs_to :ownerable, polymorphic: true
  belongs_to :hbable, polymorphic: true
  belongs_to :ruleable, polymorphic: true
  belongs_to :card
  
  belongs_to :share_poster
  
  has_many :redbag_earn_logs, dependent: :destroy
  has_many :redbag_view_logs, dependent: :destroy
  has_many :redbag_share_logs, dependent: :destroy
  
  # 有许多红包奖品
  has_many :redbag_prizes, dependent: :destroy
  accepts_nested_attributes_for :redbag_prizes, allow_destroy: true, reject_if: proc { |a| a[:name].blank? or a[:score].blank? }
  
  # 用于发送微信现金红包
  has_one :wechat_redbag_config, dependent: :destroy
  accepts_nested_attributes_for :wechat_redbag_config, allow_destroy: true, reject_if: :all_blank
  # has_one :share_hb, class_name: 'Redbag', foreign_key: 'share_hb_id'
  # belongs_to :hb, class_name: 'Redbag', foreign_key: 'share_hb_id'
  
  USE_TYPE_EVENT     = 1 # 广告红包
  USE_TYPE_SHARE     = 2 # 分享红包
  USE_TYPE_CHECKIN   = 3 # 签到红包
  USE_TYPE_USER_SEND = 4 # 用户前端发的红包 
  USE_TYPE_CASH      = 6 # 现金红包
  USE_TYPE_TASK      = 8 # 任务红包
  
  has_many :likes, as: :likeable
  
  validates :ownerable, :title, :total_money, :min_value, :max_value, presence: true
  
  scope :opened, -> { where(opened: true) }
  scope :no_complete, -> { where('total_money > sent_money') }
  scope :complete, -> { where('total_money = sent_money or total_money < sent_money') }
  scope :order_by_left_money, -> { select('redbags.*, (redbags.total_money - redbags.sent_money) as left_money').order('left_money desc') }
  scope :sorted, -> { order('sort asc') }
  scope :latest, -> { order('id desc') }
  scope :no_location_limit, -> { where(range: nil) }
  scope :can_started, -> { where('started_at is null or started_at < ?', Time.zone.now) }
  
  scope :not_share, -> { where(use_type: Redbag::USE_TYPE_EVENT ).where.not(hbable: nil, ruleable: nil) }
  
  scope :event,   -> { where(use_type: Redbag::USE_TYPE_EVENT) }#.where.not(hbable: nil, ruleable: nil) }
  # scope :poster,  -> { where(use_type: Redbag::USE_TYPE_EVENT, hbable: nil) }
  scope :task,    -> { where(use_type: Redbag::USE_TYPE_TASK) }
  scope :cash,    -> { where(use_type: Redbag::USE_TYPE_CASH) }
  scope :share,   -> { where(use_type: Redbag::USE_TYPE_SHARE) }
  scope :checkin, -> { where(use_type: Redbag::USE_TYPE_CHECKIN) }
  
  # attr_accessor :value, :num
  attr_accessor :f_value, :f_total, :f_total_money, :f_min_value, :f_max_value
  
  # 验证是否有足够的余额发红包
  validate :check_balance, on: :create
  def check_balance
    if ownerable_type == 'User' and ownerable.balance < self.total_money
      errors.add(:base, '余额不足，请先充值')
      return false
    end
  end
  
  # 验证红包最大最小金额
  validate :check_min_value_and_max_value
  def check_min_value_and_max_value
    if min_value.blank?
      errors.add(:base, '最小金额不能为空')
      return false
    end
    if max_value.blank?
      errors.add(:base, '最大金额不能为空')
      return false
    end
    
    if min_value > max_value
      errors.add(:base, '最小红包金额不能超过最大红包金额')
    end
  end
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  # 创建红包后，写交易日志
  after_create :write_trade_log
  def write_trade_log
    if ownerable_type == 'User'
      ownerable.balance -= total_money
      ownerable.save!
      
      TradeLog.create!(user_id: ownerable.id, tradeable: self, money: total_money, title: "发红包[#{self.title}]")
    end
  end
  
  # after_save :remove_wechat_redbag_config_if_no_cash_hb
  # def remove_wechat_redbag_config_if_no_cash_hb
  #   unless new_record?
  #     if (wechat_redbag_config.present? and !is_cash_hb)
  #       wechat_redbag_config.delete
  #     end
  #   end
  # end
  
  def real_share_title
    if self.share_title.blank?
      self.title
    else
      self.share_title
    end
  end
  
  def share_hb
    @share_hb ||= Redbag.find_by(id: share_hb_id)
  end
  
  def is_event_hb?
    (
      self.use_type == Redbag::USE_TYPE_EVENT and
      self.hbable.present? and 
      self.ruleable.present?
    )
  end
  
  def self.share_hbs
    # @ids = Redbag.where.not(share_hb_id: nil).pluck(:share_hb_id)
    # @hbs = Redbag.where(use_type: Redbag::USE_TYPE_SHARE).where.not(id: @ids)
    @hbs = Redbag.share.no_complete
    [['-- 无 --', nil]] + @hbs.map { |hb| [hb._format_info, hb.id] }
  end
  
  # def self.share_receiver_hbs
  #   @hbs = Redbag.opened.no_complete.where(use_type: Redbag::USE_TYPE_EVENT, hbable: nil)
  #   [['-- 无 --', nil]] + @hbs.map { |hb| [hb._format_info, hb.id] }
  # end
  
  # 发送微信现金红包的使用场景
  def self.wx_send_scenes
    [['商品促销[1-499]','PRODUCT_1'],
     ['抽奖[1-200]','PRODUCT_2'],
     ['虚拟物品兑奖[1-200]','PRODUCT_3'],
     ['企业内部福利[1-499]','PRODUCT_4'],
     ['渠道分润[1-200]','PRODUCT_5'],
     ['保险回馈','PRODUCT_6'],
     ['彩票派奖','PRODUCT_7'],
     ['税务刮奖','PRODUCT_8'],
    ]
  end
  
  # 红包奖品数据
  def self.prizes_data_for(owner)
    # puts owner
    arr = Card.opened.order('id desc') + Redbag.cash.opened.order('id desc')
    arr.map { |o| ["[#{o.ownerable.try(:uid) || o.ownerable.try(:id)}-#{o.owner_name}]#{o.title}", "#{o.class}-#{o.id}"] }
  end
  
  def _format_info
    "[#{self.title}]#{self.uniq_id} -> #{self._type == 0 ? 
    (self.total_money.to_s + ', ' + self.min_value.to_s + '~' + self.max_value.to_s) : 
    self.total_money.to_s + ', ' + self.min_value.to_s}"
  end
  
  # 记录浏览日志
  def view_for(loc, ip, user_id)
    loc = loc.blank? ? nil : "POINT(#{loc.gsub(',', ' ')})"
    RedbagViewLog.create!(redbag_id: self.id, ip: ip, user_id: user_id, location: loc)
    
    # self.add_view_count
  end
  
  def add_view_count
    self.class.increment_counter(:view_count, self.id)
  end
  
  def add_share_count
    self.class.increment_counter(:share_count, self.id)
  end
  
  def self.range_of_data_for(loc, range)
    if loc.blank?
      lat = 0
      lng = 0
    else
      lng,lat = loc.split(',')
    end
    select("redbags.*, ST_Distance(redbags.location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").where("redbags.range is null or redbags.location is null or (ST_DWithin(redbags.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), redbags.range * 1000))").order('distance asc')
  end
  
  # # 获取附近一定数量的红包
  # def self.nearby(lng, lat, size = 30, order_by = 'asc')
  #   # 获取附近的查询子表
  #   subtable = Redbag.order("location <-> 'SRID=4326;POINT(#{lng} #{lat})'::geometry").arel_table
  #   
  #   # 返回真正的数据并排序
  #   select("redbags.*, ST_Distance(location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").from(subtable).order("distance #{order_by}").limit(size)
  # end
  
  # 获取一定距离内的红包
  def self.nearby_distance(lng, lat)
      select("redbags.*, ST_Distance(redbags.location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").where("redbags.range is not null and redbags.location is not null and ST_DWithin(redbags.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), range)")#.where('distance <= range')#.order('distance asc')
  end
  
  # 通知红包所有者红包已经发完了
  def notify_owner_if_sent_done
    return if self.left_money > 0
    
    view_count = self.view_count
    earn_count = RedbagEarnLog.where(redbag_id: self.id).count
    share_count = self.share_count
    
    payload = {
      first: {
        value: "您的红包已经被抢完了！\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{self.title}",
        color: "#173177",
      },
      keyword2: {
        value: "广告浏览: #{view_count}次, 红包参与: #{earn_count}次, 广告分享: #{share_count}次",
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
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    
    user_ids << ownerable.id
    
    Message.create!(message_template_id: 5, content: payload, link: SiteConfig.wx_app_url, to_users: user_ids)
  end
  
  # 更新发送统计
  def change_sent_stats!(money)
    self.sent_count += 1
    self.sent_money += money
    self.save!
  end
  
  ###########################   JSON 字段   #########################
  def total_sent_count
    @total_sent_count ||= redbag_earn_logs.count
  end
  
  def left_money
    total_money - sent_money
  end
  
  # TODO: 暂时不实现该功能
  def likes_count
    0
  end
  
  def owner_name
    ownerable.try(:format_nickname) || ownerable.try(:email) || ''
  end
  
  def cover_image
    if hbable && hbable.try(:image)
      hbable.image.url
    else
      # 返回一个固定的官方广告图片
      'http://hb-assets.small-best.com/uploads/attachment/data/206/9d28b5fc-025f-4e9a-9be6-385c6ff93cc4.jpg?e=1816485281&token=TL7vgIdADfCg9dJGncUGqvj51t0JfO8IORBBO9JX:5rW7JZy4cwB4-Ka45JgPKW66CWs='
    end
  end
  
  def icon_image
    if hbable && hbable.try(:image)
      hbable.image.url(:small)
    else
      ownerable.try(:format_avatar_url)
    end
  end
  
  def share_image_icon
    if hbable && hbable.try(:image)
      hbable.image.url(:small)
    else
      # 使用官方二维码
      'http://hb-assets.small-best.com/uploads/attachment/data/203/a49c8241-ad48-4794-be8e-96e9be93bc7b.png?e=1815613587&token=TL7vgIdADfCg9dJGncUGqvj51t0JfO8IORBBO9JX:-5GWTEtmCheeIKbMLXz8V5nTICY='
    end
  end
  
  def grabed_with_opts(opts)
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      false
    else
      user = opts[:opts][:user]
      RedbagEarnLog.where(user_id: user.id, redbag_id: self.id).count > 0
    end
  end
  
  def disable_text_with_opts(opts)
    if !self.opened
      return "红包还未上架"
    end
    
    if self.left_money <= 0.0
      return "红包已经被抢光了"
    end
    
    if self.started_at and self.started_at > Time.zone.now
      return "红包还未开抢"
    end
    
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      return ""
    end
    
    user = opts[:opts][:user]
    if RedbagEarnLog.where(user_id: user.id, redbag_id: self.id).count > 0
      return "已经抢过红包了"
    end
    
    return ""
  end
  
  def share_poster_image(opts)
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      return ''
    end
    
    user = opts[:opts][:user]
    
    share_poster_image_for_user(user)
  end
  
  def share_poster_image_for_user(user)
    return '' if user.blank?
    
    return '' if self.ruleable_id.blank?
    return '' if self.ruleable_type != 'SharePoster'
    
    upr = UserPosterRedbag.where(user_id: user.id, redbag_id: self.id, share_poster_id: self.ruleable.id).first_or_create!
    upr.share_poster_image
  end
  
  # 获取一个随机金额
  def random_money
    if self._type == 1
      self.min_value
    else
      return 0.00 if self.min_value == 0.0 or self.left_money <= 0.0
      
      max_count = (self.left_money / self.min_value).to_i
      if max_count > 2
        # 随机金额
        min = self.min_value * 100
        max = self.max_value * 100
      
        avg = max#(min + max) / 2
        
        prng  = Random.new
        money = prng.rand(min..avg)
        money = money / 100.0
        
        money = [money, self.left_money].min
        dt = self.left_money - money
        if dt < self.min_value
          [money - self.min_value, self.min_value].max
        else
          money
        end
      elsif max_count == 2
        # 平分金额
        self.left_money / 2.0
      else
        # < 2 0 或 1
        self.left_money
      end
    end
  end
  
  ###########################   自定义输入属性开始   #####################################
  
  def uid=(val)
    self.ownerable = User.find_by(uid: val) || Admin.find_by(email: val)
  end
  
  def uid
    if ownerable_type == 'User'
      ownerable.try(:uid)
    elsif ownerable_type == 'Admin'
      ownerable.try(:email)
    else
      nil
    end
  end
  
  def self.use_types
    [
      ['广告红包', USE_TYPE_EVENT], 
      # ['任务红包', USE_TYPE_TASK], 
      # ['现金红包', USE_TYPE_CASH], 
      ['分享红包', USE_TYPE_SHARE], 
      ['签到红包', USE_TYPE_CHECKIN]
    ]
  end
  
  def self.hb_types
    [['-- 选择红包内容 --', nil]] + RedbagEvent.order('id desc').map { |e| [e.title, "RedbagEvent-#{e.id}"] }
  end
  
  def hb_type=(val)
    if val.present?
      name,id = val.split('-')
      klass = Object.const_get name
      self.hbable = klass.find_by(id: id)
    else
      self.hbable = nil
    end
  end
  
  def hb_type
    "#{self.hbable_type}-#{self.hbable_id}"
  end
  
  def self.rule_types
    arr = Question.order('id desc') + SignRule.order('id desc') + SharePoster.order('id desc') + LocationCheckin.order('id desc')
    [['-- 选择红包规则 --', nil]] + arr.map { |o| [o.try(:sign_desc) || o.try(:question) || o.try(:address) || o.try(:title), "#{o.class}-#{o.id}"] }
  end
  
  def rule_type=(val)
    if val.present?
      name,id = val.split('-')
      klass = Object.const_get name
      self.ruleable = klass.find_by(id: id)
    else
      self.ruleable = nil
    end
  end
  
  def rule_type
    "#{self.ruleable_type}-#{self.ruleable_id}"
  end
  
  def self.cards
    [['-- 无 --', nil]] + Card.opened.can_send.order('id desc').map { |o| [o.title, o.id] }
  end
  
  before_save :parse_location
  def parse_location
    if address.blank?
      return true
    end
    
    if not address_changed? and location.present?
      return true
    end
    
    loc = ParseLocation.start(address)
    if loc.blank?
      errors.add(:base, '位置不正确或者解析出错')
      return false
    end
    
    self.location = loc
  end
  
  def type_name
    is_cash_hb ? '现金红包' : '提现红包'
  end
  
  # 红包送出的情况
  def sent_status_info
    "#{total_money} / #{sent_money}"
  end
  
  # def location_str=(val)
  #   if val.blank?
  #     self.location = nil
  #   else
  #     self.location = "POINT(#{val.gsub(',', ' ')})"
  #   end
  # end
  # 
  # def location_str
  #   self.location.blank? ? nil : "#{self.location.x},#{self.location.y}"
  # end
   
  ###########################   自定义输入属性结束   #####################################
  
  def open!
    if use_type != Redbag::USE_TYPE_SHARE
      self.opened = true
      self.save!
    
      send_message_to_hb_owner
    end
  end
  
  def close!
    if use_type != Redbag::USE_TYPE_SHARE
      self.opened = false
      self.save!
    
      # send_message_to_hb_owner
    end
  end
  
  def send_message_to_hb_owner
    first = self.opened ? '您的红包已经上架' : '您的红包已经下架'
    state = self.opened ? '已上架' : '已下架'
    remark = self.opened ? '现在可以开始抢红包了~' : '很抱歉您的红包被下架了，请联系客服'
    payload = {
      first: {
        value: "#{first}\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{self.title}",
        color: "#173177",
      },
      keyword2: {
        value: state,
        color: "#173177",
      },
      remark: {
        value: remark,
        color: "#173177",
      }
    }.to_json
    
    Message.create!(message_template_id: 4, content: payload,link: SiteConfig.wx_app_url, to_users: [ownerable.id])
  end
  
end
