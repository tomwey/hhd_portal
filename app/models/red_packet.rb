class RedPacket < ActiveRecord::Base
  validates :title, :money, :quantity, presence: true
  validates :location_str, presence: true, on: :create
  
  scope :sorted, -> { order('sort asc') }
  scope :opened, -> { where(opened: true) }
    
  attr_accessor :location_str
  
  validate :check_min_value_and_max_value
  def check_min_value_and_max_value
    if _type == 0 && ( min_value.blank? or max_value.blank?)
      errors.add(:base, '随机红包必须指定最大红包以及最小红包')
    end
  end
  
  before_create :generate_unique_oid
  def generate_unique_oid
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.oid = (n.to_s + SecureRandom.random_number.to_s[2..6]).to_i
    end while self.class.exists?(:oid => oid)
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
  
  def expired?
    self.expired_at.present? and self.expired_at < Time.zone.now 
  end
  
  def closed?
    not self.opened
  end
  
  def owner
    Merchant.find_by(merch_id: owner_id)
  end
  
  def owner_name
    owner.try(:name)
  end
  
  def owner_latest_home_page
    @home_page ||= MerchantHomePage.where(merchant_id: owner_id).opened.sorted.first
    @home_page.add_hits
    @home_page
  end
  
  def add_hits
    self.class.increment_counter(:hits, self.id)
  end
  
  # def location_str=(str)
  #   return if str.blank?
  #   
  #   longitude = str.split(',').first
  #   latitude  = str.split(',').last
  #   
  #   self.location = "POINT(#{longitude} #{latitude})"#GEO_FACTORY.point(longitude, latitude)
  # end
  # 
  # def location_str
  #   return '' if self.location.blank?
  #   "#{self.location.x},#{self.location.y}"
  # end
  
  # 获取基于位置的红包列表
  def self.list_with_location(lng, lat)
    select("red_packets.*, ST_Distance(location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").order("distance asc")
  end
  
  # 获取附近的红包
  def self.nearby(lng, lat, size = 30, order_by = 'asc')
    # 获取附近的查询子表
    subtable = RedPacket.order("location <-> 'SRID=4326;POINT(#{lng} #{lat})'::geometry").arel_table
    
    # 返回真正的数据并排序
    select("red_packets.*, ST_Distance(location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").from(subtable).order("distance #{order_by}").limit(size)
  end
  
  # 获取一定距离内的红包
  def self.nearby_distance(lng, lat, distance = 5000)
      select("red_packets.*, ST_Distance(location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").where("ST_DWithin(red_packets.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), #{distance})").order('distance')
  end
  
end

# t.integer :oid
# t.string :title, null: false
# t.string :image
# t.decimal :money, precision: 16, scale: 2, null: false
# t.integer :quantity, null: false
# t.datetime :expired_at
# t.integer :owner_id
# t.string :memo
# t.st_point :location, geographic: true
# t.integer :_type, default: 0 # 0 表示随机红包，1 表示固定红包
# t.decimal :min_value, precision: 16, scale: 2
# t.decimal :max_value, precision: 16, scale: 2
# t.integer :sort, default: 0
# t.boolean :opened, default: true 
# 
# t.timestamps null: false
