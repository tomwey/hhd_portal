class PartinViewLog < ActiveRecord::Base
  belongs_to :partin
  belongs_to :user
  
  after_create :add_view_count
  def add_view_count
    partin.add_view_count
  end
  
  def from_user
    User.find_by(id: from_user_id)
  end
  
end
