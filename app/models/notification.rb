class Notification < ActiveRecord::Base
  validates :title, :content, presence: true
  
  after_create :send_notification
  def send_notification
    NotificationSendJob.set(wait: 1.seconds).perform_later(self.id)
  end
  
end
