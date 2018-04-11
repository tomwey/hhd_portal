class UserSession < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      self.uniq_id = SecureRandom.urlsafe_base64(nil, false)
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :add_user_sessions_count
  def add_user_sessions_count
    user.add_use_sessions_count
  end
  
  def group_by_criteria
    created_at.to_date.to_s(:db)
  end
  
end
