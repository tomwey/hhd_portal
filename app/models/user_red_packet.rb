class UserRedPacket < ActiveRecord::Base
  validates :user_id, :hb_id, :grabed_ip, :opened_ip, presence: true
  
  attr_accessor :ad
  
  before_create :generate_oid
  def generate_oid
    begin
      self.oid = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:oid => oid)
  end
  
  def user
    User.find_by(uid: user_id)
  end
  
  def red_packet
    RedPacket.find_by(oid: hb_id)
  end
  
end
