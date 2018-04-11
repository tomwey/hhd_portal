class Event < ActiveRecord::Base
  belongs_to :ownerable, polymorphic: true
  belongs_to :ruleable, polymorphic: true
  
  has_many :event_earn_logs, dependent: :destroy
  has_many :event_view_logs, dependent: :destroy
  has_many :event_share_logs, dependent: :destroy
  
  has_many :reports, dependent: :destroy
  
  has_many :hongbaos, dependent: :destroy
  
  has_many :likes, as: :likeable
  
  validates :title, :image, :ownerable, :body, presence: true
  
  mount_uploader :image, ImageUploader
  
  attr_accessor :latest_log_size, :uid#, :rule_type, :question, :_answers, :answer, :address, :accuracy, :checkined_at
  
  scope :valid,  -> { with_state([:approved, :progressing]) }
  scope :sorted, -> { order('sort asc') }
  
  attr_accessor :location_str, 
                :total_money_0, :total_money_1, :min_value, :max_value, :value, :hb_type, # 红包相关的虚拟属性
                :question, :_answers, :answer,                          # 题目规则相关的虚拟属性
                :address, :accuracy, :checkined_at,                     # 签到规则相关的虚拟属性
                :rule_type
  
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
  
  after_create :notify_backend_manager
  def notify_backend_manager
    payload = {
      first: {
        value: "收到一个红包活动，需要审核，请速查看\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{ownerable.try(:format_nickname)}",
        color: "#173177",
      },
      keyword2: {
        value: "待审核",
        color: "#173177",
      },
      remark: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: [64784012, 90242816]).pluck(:id).to_a
    Message.create!(message_template_id: 8, link: SiteConfig.wx_app_url, content: payload, to_users: user_ids)
  end
  
  before_save :parse_location
  def parse_location
    if location_str.blank?
      return true
    end
    
    loc = ParseLocation.start(location_str)
    if loc.blank?
      errors.add(:base, '位置不正确或者解析出错')
      return false
    end
    
    self.location = loc
  end
  
  before_save :check_body
  def check_body
    if body_url.blank? and body.blank?
      errors.add(:base, '活动详情或活动详情地址至少有一个必填')
      return false
    end
    
    return true
  end
  
  # 当前绑定的红包
  def current_hb
    @hb ||= Hongbao.find_by(uniq_id: self.current_hb_id)
  end
  
  # 分享红包
  def share_hb
    @share_hb ||= Hongbao.find_by(uniq_id: self.share_hb_id)
  end
  
  def hb_left_money
    current_hb.left_money
  end
  
  def state_name
    I18n.t("common.#{state}")
  end
  
  def grabed_with_opts(opts)
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      false
    else
      user = opts[:opts][:user]
      EventEarnLog.where(user_id: user.id, event_id: self.id, hb_id: current_hb.uniq_id).count > 0
    end
  end
  
  def disable_text_with_opts(opts)
    if self.can_approve?
      return "活动还在审核中"
    end
    
    if current_hb.left_money <= 0.0
      return "红包已经被抢光了"
    end
    
    if self.started_at and self.started_at > Time.zone.now
      return "红包活动还未开始"
    end
    
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      return ""
    end
    
    user = opts[:opts][:user]
    if EventEarnLog.where(user_id: user.id, event_id: self.id, hb_id: current_hb.uniq_id).count > 0
      return "已经抢过红包了"
    end
    
    return ""
  end
  
  def add_view_count
    self.class.increment_counter(:view_count, self.id)
  end
  
  def add_share_count
    self.class.increment_counter(:share_count, self.id)
  end
  
  def from_owner_name
    if ownerable_type == 'User'
      "-来自#{ownerable.try(:format_nickname)}"
    elsif ownerable_type == 'Admin'
      '-来自系统'
    else
      ''
    end
  end
  
  def latest_earns
    @logs ||= event_earn_logs.order('id desc').limit(self.latest_log_size || 20)
  end
  
  # 获取基于位置的红包列表
  def self.list_with_location(lng, lat)
    select("events.*, ST_Distance(events.location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance")#.order("distance asc")
  end
  
  # 获取附近的红包
  def self.nearby(lng, lat, size = 30, order_by = 'asc')
    # 获取附近的查询子表
    subtable = Event.order("location <-> 'SRID=4326;POINT(#{lng} #{lat})'::geometry").arel_table
    
    # 返回真正的数据并排序
    select("events.*, ST_Distance(location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").from(subtable).order("distance #{order_by}").limit(size)
  end
  
  # 获取一定距离内的红包
  def self.nearby_distance(lng, lat, distance = 5000)
      select("events.*, ST_Distance(location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").where("ST_DWithin(events.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), #{distance})").range_of_data_for(lng,lat).order('distance')
  end
  
  # 获取指定范围内的数据
  def self.range_of_data_for(lng, lat)
    where("events.range is null or events.location is null or (ST_DWithin(events.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), events.range * 1000))")
  end
  
  def do_approve
    if started_at.blank?
      # 审核通过立即开始抢红包
      if can_in_progress?
        in_progress
      end
    else
      # 启动一个job自动设置开始抢红包
      # CancelOrderJob.set(wait: 30.minutes).perform_later(self.id)
      if can_in_progress? 
        if Time.zone.now < self.started_at
          StartHongbaoJob.set(wait_until: self.started_at).perform_later(self.id)
        else
          in_progress
        end
      end
    end
    
    # 发送消息
    send_message
    
  end
  
  def send_message
    payload = {
      first: {
        value: "#{self.state == 'rejected' ? '您的广告活动未通过审核' : '您的广告活动已经通过审核'}",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{self.title}",
        color: "#173177",
      },
      keyword2: {
        value: "#{self.state == 'rejected' ? '审核未通过' : '审核通过'}",
        color: "#173177",
      },
      remark: {
        value: "#{self.state == 'rejected' ? '很抱歉您的活动未通过审核，请联系客服' : '可以开始抢红包了~'}",
        color: "#173177",
      }
    }.to_json
    
    Message.create!(message_template_id: 4, content: payload,link: SiteConfig.wx_app_url, to_users: [ownerable.id])
  end
  
  # 定义状态机
  state_machine initial: :pending do # 默认状态
    state :approved  # 审核通过
    state :rejected  # 未审核通过
    state :progressing # 抢红包进行中，会根据started_at字段来处理
    state :canceled  # 已取消，各种原因的取消
    state :completed # 已完成，正常抢完所有红包
    
    # 审核
    after_transition [:pending, :rejected] => :approved do |event, transition|
      # TODO: 记录活动操作日志
      event.do_approve
    end
    event :approve do
      transition [:pending, :rejected] => :approved
    end
    
    # 拒绝通过审核
    after_transition [:pending, :approved] => :rejected do |event, transition|
      # TODO: 记录活动操作日志
      event.send_message
    end
    event :reject do
      transition [:pending, :approved] => :rejected
    end
    
    # 启动抢红包，如果没有设置started_at，那么系统审核通过后，自动开始进入抢红包环节，否则系统到该时间启动抢红包
    after_transition :approved => :progressing do |event, transition|
      # TODO: 记录活动操作日志
    end
    event :in_progress do
      transition :approved => :progressing
    end
    
    # 取消该红包活动，在活动审核通过或者正在进行抢红包状态，可以进行取消操作
    after_transition [:approved, :progressing] => :canceled do |event, transition|
      # TODO: 记录日志
    end
    event :cancel do
      transition [:approved, :progressing] => :canceled
    end
    
    # 完成抢红包活动，系统来处理该活动的状态改变
    after_transition :in_progress => :completed do |event, transition|
      # TODO: 记录日志
    end
    event :complete do
      transition :in_progress => :completed
    end
    
  end # end state define
  
end

# create_table :events do |t|
#   t.integer    :uniq_id                                  # 系统自动生成一个唯一的业务id标识
#   t.string     :title, null: false, default: ''          # 活动主题
#   t.string     :image, null: false                       # 活动封面图
#   t.string     :body                                     # 活动内容
#   t.references :ownerable, polymorphic: true, index: true, null: false # 活动所有者
#   t.integer    :hbid, index: true                        # 所属的红包
#   t.st_point   :location, geographic: true               # 活动范围
#   t.integer    :range                                    # 活动范围，单位千米
#   t.string     :body_url                                 # 活动内容地址，商家可以自定义自己的活动内容也
#   t.datetime   :started_at                               # 活动红包开抢时间
#   t.string     :state, default: 'pending'                # 活动信息状态
#   t.integer    :view_count,  default: 0                  # 活动浏览次数
#   t.integer    :share_count, default: 0                  # 活动分享转发次数
#   t.integer    :likes_count, default: 0                  # 活动点赞数
#   t.integer    :sent_hb_count, default: 0                # 当前红包红包已经领取了的人数
#   t.references :ruleable, polymorphic: true, index: true # 活动规则
#   t.integer    :sort, default: 0, index: true            # 显示顺序
#   t.timestamps null: false
# end

