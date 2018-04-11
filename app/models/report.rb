class Report < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  
  validates :content, :event_id, presence: true
end
