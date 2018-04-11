class CheckinRule < ActiveRecord::Base
  validates :address, :accuracy, presence: true
  
  before_save :parse_location
  def parse_location  
    if self.location.present?
      return true
    end
      
    loc = ParseLocation.start(address)
    if loc.blank?
      errors.add(:base, '位置不正确或者解析出错')
      return false
    end
    
    self.location = loc
    return true
  end
  
  def verify(hash_data)
    if hash_data.blank? or hash_data.location.blank?
      return { code: -1, message: '参数不正确，必须提供签到位置坐标，参数名为location' }
    end
    
    if self.location.blank?
      return { code: -2, message: '无效的活动规则，签到活动必须提供有效的签到位置' }
    end
    
    loc = hash_data.location
    if loc.is_a? String
      lat,lng = loc.split(',')
    elsif loc.is_a? Hash
      lat = loc['lat']
      lng = loc['lng']
    else
      lat = 0
      lng = 0
    end
    
    distance = ParseLocation.calc_distance([lat.to_f, lng.to_f], [self.location.y, self.location.x])
    if distance > self.accuracy
      return { code: 6005, message: '超出了签到位置范围' }
    end
    
    return { code: 0, message: 'ok' }
  end
end
