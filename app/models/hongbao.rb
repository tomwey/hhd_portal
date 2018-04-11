class Hongbao < ActiveRecord::Base
  # belongs_to :hbable, polymorphic: true
  belongs_to :event
  
  belongs_to :hbable, polymorphic: true
  belongs_to :ruleable, polymorphic: true
  
  validates :total_money, :min_value, :max_value, presence: true
  
  attr_accessor :value, :quantity, :num
  
  USE_TYPE_BASE = 1
  USE_TYPE_SHARE = 2
  
  validate :check_min_value_and_max_value
  def check_min_value_and_max_value
    if min_value.blank? or max_value.blank?
      errors.add(:base, '值不能为空')
      return false
    end
    if min_value > max_value
      errors.add(:base, '最小红包金额不能超过最大红包金额')
    end
  end
  
  def self.hb_types
    [['-- 选择红包内容 --', nil]] + Event.all.map { |e| [e.title, "Event-#{e.id}"] }
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
    arr = Question.order('id desc') + LocationCheckin.order('id desc')
    [['-- 选择红包规则 --', nil]] + arr.map { |o| [o.try(:question) || o.try(:address), "#{o.class}-#{o.id}"] }
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
  
  def location_str=(val)
    self.location = val.blank? ? nil : "POINT(#{val.gsub(',', ' ')})"
  end
  
  def location_str
    self.location.blank? ? nil : "#{self.location.x},#{self.location.y}"
  end
  
  def use_type_info
    Hongbao.use_type_name(self.use_type)
  end
  
  def self.use_type_name(ut)
    I18n.t("common.hongbao.use_type_#{ut}")
  end
  
  def self.all_use_types
    [[use_type_name(USE_TYPE_BASE), USE_TYPE_BASE],[use_type_name(USE_TYPE_SHARE), USE_TYPE_SHARE]]
  end
  
  def num=(n)
    if self._type == 1
      # puts self[:value]
      self.total_money = n.to_i * self.value
    end
  end
  
  def num
    if self._type == 1
      (self.total_money / self.min_value).to_i
    else
      nil
    end
  end
    
  def value=(val)
    if self._type == 1
      self.min_value = self.max_value = val
    else
      
    end
  end
  
  def value
    if self._type == 1
      self.min_value
    else
      nil
    end
  end
  
  def write_send_log_for!(operator_type, operator_id)
    self.operator_type = operator_type
    self.operator_id   = operator_id
    self.save!
  end
  
  def random_money
    if self._type == 1
      self.min_value
    else
      return 0.00 if self.min_value == 0.0
      
      max_count = (self.left_money / self.min_value).to_i
      if max_count > 2
        # 随机金额
        min = self.min_value * 100
        max = self.max_value * 100
      
        prng = Random.new
        money = prng.rand(min..max)
        money = money / 100.0
        [money, self.left_money].min
      elsif max_count == 2
        # 平分金额
        self.left_money / 2.0
      else
        # < 2 0 或 1
        self.left_money
      end
    end
  end
  
  def add_sent_money!(money)
    if money > 0
      new_val = self.sent_money + money
      if new_val <= self.total_money
        self.sent_money = new_val
        self.save!
      end
    end
  end
  
  def left_money
    self.total_money - self.sent_money < 0 ? 0 : self.total_money - self.sent_money
  end
  
  # 设置固定红包类型的金额
  # before_save :set_value_for_fixed_money
  # def set_value_for_fixed_money
  #   self.min_value = self.max_value = self.value
  # end
  
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
end
