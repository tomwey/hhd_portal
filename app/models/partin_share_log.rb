class PartinShareLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :partin
  
  after_create :add_share_count
  def add_share_count
    partin.add_share_count if partin
  end
  
  def from_user
    User.find_by(id: from_user_id)
  end
  
end
