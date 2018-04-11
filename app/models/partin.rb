class Partin < ActiveRecord::Base
  belongs_to :ruleable, polymorphic: true
  belongs_to :winnable, polymorphic: true
  belongs_to :info_item, foreign_key: 'item_id'
  belongs_to :merchant
  
  has_many :partin_take_logs, dependent: :destroy
  has_many :partin_view_logs, dependent: :destroy
  
  has_one :partin_share_config, dependent: :destroy
  
  validates :winnable_id, :winnable_type, :win_type, presence: true
  
  scope :opened,   -> { where(opened: true) }
  scope :can_take, -> { where(can_take: true) }
  scope :onlined,  -> { where('online_at is null or online_at < ?', Time.zone.now) }
  scope :no_location_limit, -> { where(range: nil) }
  scope :join_merchant, -> { joins(:merchant).select('partins.*') }
  scope :sorted,   -> { join_merchant.select('(merchants.score + partins.sort) as sort_order').order('sort_order desc') }
  scope :for_areas, -> (area_ids) { where("areas = '{}' or (ARRAY[?]::int[] && areas)", area_ids) }
  
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
  
  before_save :parse_location
  def parse_location
    if location_str.blank?
      return true
    end
    
    if (!location_str_changed?) and location.present?
      return true
    end
    
    loc = ParseLocation.start(location_str)
    if loc.blank?
      errors.add(:base, '位置不正确或者解析出错')
      return false
    end
    
    self.location = loc
  end
  
  def view_for!(user_id, loc, ip, from_type = 0, from_user_id = nil)
    PartinViewLog.create!(partin_id: self.id, 
                          user_id: user_id, 
                          ip: ip, 
                          location: loc, 
                          from_type: from_type,
                          from_user_id: from_user_id)
  end
  
  def take_tip
    if self.ruleable_type == 'LocationCheckin'
      I18n.t("common.#{self.ruleable_type}.grab_tip", 
        accuracy: self.ruleable.try(:accuracy))
    else
      self.rule_answer_tip || '题目的答案在上面广告内容中查找，注意：只有一次回答机会！回答正确才有机会抢红包！'
    end
  end
  
  def item_image_url
    if self.item_id.blank?
      ''
    else
      info_item.image.url(:small)
    end
  end
  
  def item_title
    if self.item_id.blank?
      ''
    else
      info_item.title
    end
  end
    
  # def open!
  #   self.opened = true
  #   self.save!
  # end
  #
  # def close!
  #   self.opened = false
  #   self.save!
  # end
  def open!
    if self.winnable_type == 'Redpack'
      hb = self.winnable
      money = hb.total_money - hb.sent_money
      if money > 0
        if money < self.merchant.balance
          
          # 写交易记录
          PayLog.create!(money: -money, merchant: merchant, payable: self, title: '红包广告上架')
          
          self.opened = true
          self.save!
          
          return true
        else
          return false
        end
      else
        self.opened = true
        self.save!
        return true
      end
    else
      self.opened = true
      self.save!
      return true
    end
  end
  
  def close!
    if self.winnable_type == 'Redpack'
      hb = self.winnable
      money = hb.total_money - hb.sent_money
      if money > 0
        # 写交易记录
        PayLog.create!(money: money, merchant: merchant, payable: self, title: '红包广告下架')
      end
      self.opened = false
      self.save!
      return true
    else
      self.opened = false
      self.save!
      return true
    end
  end
  
  # 获取一定距离内的红包
  def self.nearby_distance(lng, lat)
      select("partins.*, ST_Distance(partins.location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").where("partins.range is not null and partins.location is not null and ST_DWithin(partins.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), range)")#.where('distance <= range')#.order('distance asc')
  end
  
  def taked_with_opts(opts)
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      false
    else
      user = opts[:opts][:user]
      user.taked?(self)
    end
  end
  
  def disable_text_with_opts(opts)
    if !self.opened
      return "还没上架，不能参与"
    end
    
    if !self.can_take
      return "下手太慢了，已经被抢完了"
    end
    
    if self.online_at and self.online_at > Time.zone.now
      return "还未开始，请耐心等待'"
    end
    
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      return ""
    end
    
    user = opts[:opts][:user]
    if user.taked?(self)
      return "您已经参与过了"
    end
    
    return ""
  end
  
  def marked_as_take_done!
    self.can_take = false
    self.save!
    
    # 如果广告奖励被抢完了，通知广告商家
    notify_owner_if_sent_done
    
    # 通知平台管理员，所有广告奖励快被抢完了
    notify_backend_manager_if_needed
  end
  
  def notify_owner_if_sent_done
    view_count = self.view_count
    earn_count = PartinTakeLog.where(partin_id: self.id).count
    share_count = self.share_count
    
    payload = {
      first: {
        value: "您的广告已经被抢完了！\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{self.info_item.try(:title)}",
        color: "#173177",
      },
      keyword2: {
        value: "浏览: #{view_count}次, 参与: #{earn_count}次, 分享: #{share_count}次",
        color: "#173177",
      },
      keyword3: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "现在继续去发广告吧~",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    
    # user_ids << ownerable.id
    ids = AdminUser.where(merchant_id: self.merchant_id).pluck(:wx_user_id)
    
    if ids.any?
      user_ids = user_ids + ids
    end
    
    Message.create!(message_template_id: 5, content: payload, link: '', to_users: user_ids)
  end
  
  def notify_backend_manager_if_needed
    # 取平台上还剩的总的红包金额
    @left_count = Partin.opened.can_take.count
    
    if @left_count <= 0
      send_redbag_left_money_low(0)
      return
    end
    
    if @left_count < 2
      send_redbag_left_money_low(2)
      return
    end
    
  end
  
  def send_redbag_left_money_low(money)
    msg = money == 0 ? "没有可参与的广告了" : "平台广告还剩不到#{money}个。"
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
        value: "需要尽快去增加广告~",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    
    Message.create!(message_template_id: 6, content: payload,link: SiteConfig.wx_app_url, to_users: user_ids)
  end
  
  def has_share_prize?
    false# partin_share_config && partin_share_config.winnable && partin_share_config.winnable.has_left?
  end
  
  def add_view_count
    self.class.increment_counter(:view_count, self.id)
  end
  
  def add_share_count
    self.class.increment_counter(:share_count, self.id)
  end
  
  def add_take_count
    self.class.increment_counter(:take_count, self.id)
  end
  
  def self.items_for(merchant_id)
    InfoItem.where(merchant_id: merchant_id).order('id desc').map { |o| [o.title, o.id] }
  end
  
  def self.rule_types_for(merchant_id)
    arr = Question.where(merchant_id: merchant_id).order('id desc')
    [['-- 选择参与规则 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
  end
  
  def self.win_types_for(merchant_id)
    arr = Redpack.where(merchant_id: merchant_id).order('id desc')
    [['-- 选择参与奖励 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
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
    
  def win_type=(val)
    if val.present?
      name,id = val.split('-')
      klass = Object.const_get name
      self.winnable = klass.find_by(id: id)
    else
      self.winnable = nil
    end
  end
  
  def win_type
    "#{self.winnable_type}-#{self.winnable_id}"
  end
  
end
