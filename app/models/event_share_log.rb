class EventShareLog < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  
  validates :event_id, :ip, presence: true
  
  after_create :add_share_count
  def add_share_count
    event.add_share_count
  end
    
end
