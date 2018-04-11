class Item < ActiveRecord::Base
  belongs_to :ownerable, polymorphic: true
  belongs_to :ruleable, polymorphic: true
  belongs_to :item_content, class_name: 'RedbagEvent'
  
  has_many :item_win_logs, dependent: :destroy
  
  has_many :item_prizes, -> { where(use_type: 0) }, dependent: :destroy
  accepts_nested_attributes_for :item_prizes, allow_destroy: true, reject_if: proc { |a| a[:score].blank? }
  
  has_many :share_item_prizes, -> { where(use_type: ItemPrize::USE_TYPE_SHARE) }, dependent: :destroy, class_name: 'ItemPrize'
  accepts_nested_attributes_for :share_item_prizes, allow_destroy: true, reject_if: proc { |a| a[:score].blank? }
  
  delegate :image, to: :item_content, prefix: false, allow_nil: true
  delegate :body, to: :item_content, prefix: false, allow_nil: true
  
  validates :ownerable_type, :ownerable_id, :title, presence: true
  
  mount_uploader :share_icon, AvatarUploader
  
  scope :opened, -> { where(opened: true) }
  scope :sorted, -> { order('sort desc') }
  scope :no_location_limit, -> { where(range: nil) }
  scope :no_complete, -> {}#{ includes(:item_prizes).where(item_prizes: { can_prize: true }) }
  
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
  
  # 获取一定距离内的红包
  def self.nearby_distance(lng, lat)
      select("items.*, ST_Distance(items.location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").where("items.range is not null and items.location is not null and ST_DWithin(items.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), range)")#.where('distance <= range')#.order('distance asc')
  end
  
  ##########################  业务方法  ##########################
  def view_for(loc, ip, user_id)
    loc = loc.blank? ? nil : "POINT(#{loc.gsub(',', ' ')})"
    ItemViewLog.create!(item_id: self.id, ip: ip, user_id: user_id, location: loc)
  end
  
  def add_view_count
    self.class.increment_counter(:view_count, self.id)
  end
  
  def add_share_count
    self.class.increment_counter(:share_count, self.id)
  end
  
  def can_prize?
    @count ||= item_prizes.where(can_prize: true).count
    @count > 0
  end
  
  def send_prize
    @prizes ||= item_prizes.where(can_prize: true)
    
    @total = @prizes.map { |prize| prize.score }.sum
    
    prize = nil
    
    @prizes.each do |po|
      prng  = Random.new
      rand_num  = prng.rand(1..@total)
      if rand_num <= po.score
        result = po
        break
      else
        @total -= po.score
      end
    end
    
    prize
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
  
  def self.rule_types
    arr = Question.order('id desc') + SignRule.order('id desc') + LocationCheckin.order('id desc')
    [['-- 选择红包规则 --', nil]] + arr.map { |o| [o.try(:sign_desc) || o.try(:question) || o.try(:address), "#{o.class}-#{o.id}"] }
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
  
  ######## JSON ########
  def cover_image
    if self.image
      self.image.url(:large)
    else
      # 返回一个固定的官方广告图片
      'http://hb-assets.small-best.com/uploads/attachment/data/206/9d28b5fc-025f-4e9a-9be6-385c6ff93cc4.jpg?e=1816485281&token=TL7vgIdADfCg9dJGncUGqvj51t0JfO8IORBBO9JX:5rW7JZy4cwB4-Ka45JgPKW66CWs='
    end
  end
  
  def icon_image
    if self.image
      self.image.url(:small)
    else
      ownerable.try(:format_avatar_url)
    end
  end
    
  def grabed_with_opts(opts)
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      false
    else
      user = opts[:opts][:user]
      return user.grabed_item?(self)
      # RedbagEarnLog.where(user_id: user.id, redbag_id: self.id).count > 0
    end
  end
  
  def has_share_prizes
    @share_count ||= share_item_prizes.where(can_prize: true).count
    @share_count > 0
  end
  
  def disable_text_with_opts(opts)
    if !self.opened
      return "红包还未上架"
    end
    
    if item_prizes.where(can_prize: true).count == 0
      return "红包已经被抢光了"
    end
    
    if self.started_at and self.started_at > Time.zone.now
      return "活动还未开始"
    end
    
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      return ""
    end
    
    user = opts[:opts][:user]
    if user.grabed_item?(self)
      return "已经抢过红包了"
    end
    
    return ""
  end
  
  ###########################   自定义输入属性结束   #####################################
  
  def open!
    # if use_type != Redbag::USE_TYPE_SHARE
      self.opened = true
      self.save!
    
      send_message_to_hb_owner
    # end
  end
  
  def close!
    # if use_type != Redbag::USE_TYPE_SHARE
      self.opened = false
      self.save!
    
      # send_message_to_hb_owner
    # end
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
