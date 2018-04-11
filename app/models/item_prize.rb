class ItemPrize < ActiveRecord::Base
  belongs_to :item
  belongs_to :prizeable, polymorphic: true
  
  validates :score, :prizeable_type, :prizeable_id, presence: true
  
  USE_TYPE_SHARE = 1
  
  def self.prize_types
    redbags = Redbag.order('id desc').map { |o| ["[红包]#{o.title}", "#{o.class}-#{o.id}"] }
    cards = Card.order('id desc').map { |o| ["[卡]#{o.title}", "#{o.class}-#{o.id}"] }
    
    [['-- 选择奖项 --', nil]] + redbags + cards
  end
  
  def prize_type=(val)
    if val.present?
      name,id = val.split('-')
      klass = Object.const_get name
      self.prizeable = klass.find_by(id: id)
    else
      self.prizeable = nil
    end
  end
  
  def prize_type
    "#{self.prizeable_type}-#{self.prizeable_id}"
  end
  
  def send_to_user(user, ip, loc)
    prizeable.send_to_user(user, ip, loc)
  end
end
