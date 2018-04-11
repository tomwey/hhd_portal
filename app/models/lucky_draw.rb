class LuckyDraw < ActiveRecord::Base
  validates :title, :plate_image, :prize_desc, presence: true
  
  has_many :lucky_draw_items, dependent: :destroy
  has_many :lucky_draw_prize_logs, dependent: :destroy
  
  accepts_nested_attributes_for :lucky_draw_items, allow_destroy: true
  
  belongs_to :ownerable, polymorphic: true
  
  mount_uploader :image, ImageUploader
  mount_uploader :plate_image, CommonImageUploader
  mount_uploader :arrow_image, CommonImageUploader
  mount_uploader :background_image, CommonImageUploader
  
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
  
  def location_str=(val)
    if val.blank?
      self.location = nil
    else
      self.location = "POINT(#{val.gsub(',', ' ')})"
    end
  end
  
  def location_str
    self.location.blank? ? nil : "#{self.location.x},#{self.location.y}"
  end
  
  ###########################   自定义输入属性结束   #####################################
  
  # 记录浏览日志
  def view_for(loc, ip, user_id)
    loc = loc.blank? ? nil : "POINT(#{loc.gsub(',', ' ')})"
    # RedbagViewLog.create!(redbag_id: self.id, ip: ip, user_id: user_id, location: loc)
    LuckyDrawViewLog.create!(lucky_draw_id: self.id, ip: ip, user_id: user_id, location: loc)
    # self.add_view_count
  end
  
  def add_view_count
    self.class.increment_counter(:view_count, self.id)
  end
  
  def add_draw_count
    self.class.increment_counter(:draw_count, self.id)
  end
  
  def user_prized_count(opts)
    if opts.blank? or opts[:opts].blank? or opts[:opts][:user].blank?
      0
    else
      user = opts[:opts][:user]
      # true
      LuckyDrawPrizeLog.where(user_id: user.id, lucky_draw_id: self.id).count
    end
  end
  
  def has_prizes?
    @count ||= lucky_draw_items.where('quantity is null or quantity > sent_count').where('score is not null and score > 0').count > 0
  end
  
  def real_arrow_image_url
    if self.arrow_image.present?
      self.arrow_image.url
    elsif CommonConfig.default_lucky_draw_arrow_image
      CommonConfig.default_lucky_draw_arrow_image
    else
      ''
    end
  end
  
  def real_background_image_url
    if self.background_image.present?
      self.background_image.url
    elsif CommonConfig.default_lucky_draw_background_image
      CommonConfig.default_lucky_draw_background_image
    else
      ''
    end
  end
  
  def open!
    self.opened = true
    self.save!
  end
  
  def close!
    self.opened = false
    self.save!
  end
  
  def win_prize(user)
    if user.blank?
      @items = lucky_draw_items.where('quantity is null or quantity > sent_count').where('score is not null and score != 0')
      @total = @items.map { |item| item.score }.sum
    else
      
      whitelist = SiteConfig.send("cj_#{self.uniq_id}_whitelist").split(';')
      user_ids = []
      prize_ids = []
      prizes = {}
      whitelist.each do |o|
        uid,prize_id = o.split('-');
        user_ids << uid.to_s
        prize_ids << prize_id.to_s
        prizes[uid.to_s] = prize_id.to_s
      end
      # puts user_ids
      # puts prize_ids
      # puts prizes
      if user_ids.include?(user.uid.to_s)
        return lucky_draw_items.where('quantity is null or quantity > sent_count').where('score is not null and score != 0').where(uniq_id: prizes[user.uid.to_s]).first
      else
        @items = lucky_draw_items.where.not(uniq_id: prize_ids).where('quantity is null or quantity > sent_count').where('score is not null and score != 0')
        @total = @items.map { |item| item.score }.sum
      end
      
    end
    
    # puts @total
    result = nil
    
    @items.each do |item|
      prng  = Random.new
      rand_num  = prng.rand(1..@total)
      # puts rand_num.to_s + ':' + item.score.to_s
      if rand_num <= item.score
        result = item
        break
      else
        @total -= item.score
      end
    end
    
    return result
  end
  
end
