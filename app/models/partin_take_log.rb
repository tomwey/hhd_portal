class PartinTakeLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :partin
  belongs_to :resultable, polymorphic: true
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :add_take_count
  def add_take_count
    partin.add_take_count
    
    create_user_merchant_relationship
  end
  
  def from_user
    User.find_by(id: from_user_id)
  end
  
  private
  def create_user_merchant_relationship
    UserMerchant.where(user_id: user.id, merchant_id: partin.merchant_id).first_or_create
    tag = MerchantTag.where(merchant_id: partin.merchant_id, name: partin.merchant.try(:name)).first_or_create
    UserTag.where(user_id: user.id, tag_id: tag.id).first_or_create
  end
  
end
