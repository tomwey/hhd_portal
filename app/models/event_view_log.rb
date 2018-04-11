class EventViewLog < ActiveRecord::Base
  belongs_to :event
  validates :event_id, :ip, presence: true
  
  after_create :add_view_count
  def add_view_count
    event.add_view_count
  end
  
  def user
    User.find_by(uid: user_id)
  end
end
