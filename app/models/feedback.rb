class Feedback < ActiveRecord::Base
  has_many :attachments, as: :attachmentable
  belongs_to :user
  
  validates :content, presence: true
end
