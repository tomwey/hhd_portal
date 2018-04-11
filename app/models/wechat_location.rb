class WechatLocation < ActiveRecord::Base
  belongs_to :user
  
  after_create :geocode_loc
  def geocode_loc
    GeocodeLocJob.set(wait: 1.seconds).perform_later(self.id)
  end
end
