class Banner < ActiveRecord::Base
  validates :image, :link_type, presence: true
  mount_uploader :image, BannerImageUploader
  
  scope :opened, -> { where(opened: true) }
  scope :sorted, -> { order('sort asc') }
  
  # attr_accessor :_link_type
  
  LINK_TYPES = [['无', 0], ['网页地址',1], ['红包广告', 2], ['优惠卡', 3]]

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
  
  validate :check_link_value
  def check_link_value
    if link_type > 0
      if link.blank?
        msg = if link_type == 1
          '网页地址不能为空'
        elsif link_type == 2
          '必须选择一个红包广告'
        elsif link_type == 3
          '必须选择一个优惠卡'
        else
          ''
        end
        errors.add(:base, msg)
        return false
      end
    end
    return true
  end
  
  def _link_type=(val)
    # puts val
    self.link_type = val
  end

  # def _link_type
  #   self.link_type
  # end
  
  def link_type_name
    case link_type
    when 0 then '无'
    when 1 then '网页'
    when 2 then '红包广告'
    when 3 then '优惠卡'
    else ''
    end
  end
  
  def linkable
    cls,id = link.split(':')
    klass = cls.classify.constantize
    klass.find_by(id: id)
  end
  
  def adable
    if link.blank?
      nil
    else
      if link.start_with?('http://') or link.start_with?('https://')
        { type: 'url', link: link }
      elsif link.start_with?('event:')
        cls,id = link.split(':')
        klass = cls.classify.constantize
        klass.find_by(uniq_id: id)
      elsif link.start_with?('page:')
        cls,slug = link.split(':')
        klass = cls.classify.constantize
        klass.find_by(slug: slug)
      else
        nil
      end
    end
  end
  
  def event
    cls,id = link.split(':')
    klass = cls.classify.constantize
    klass.find_by(uniq_id: id)
  end
  
  def page
    cls,slug = link.split(':')
    klass = cls.classify.constantize
    klass.find_by(slug: slug)
  end
  
  # def format_link
  #   if link.start_with?('http://') or link.start_with?('https://')
  #     link
  #   else
  #     arr = link.split(':')
  #     if arr.first == 'event'
  #       
  #     else
  #       
  #     end
  #   end
  # end
  
end
