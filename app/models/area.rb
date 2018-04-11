class Area < ActiveRecord::Base
  validates :address, :range, presence: true
  
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
  
  # 获取一定距离内的红包
  def self.nearby_distance(lng, lat)
      select("areas.*, ST_Distance(areas.location, 'SRID=4326;POINT(#{lng} #{lat})'::geometry) as distance").where("areas.range is not null and areas.location is not null and ST_DWithin(areas.location, ST_GeographyFromText('SRID=4326;POINT(#{lng} #{lat})'), range)")#.where('distance <= range')#.order('distance asc')
  end
  
end
