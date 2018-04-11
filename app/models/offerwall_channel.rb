class OfferwallChannel < ActiveRecord::Base
  validates :name, :appid, :app_secret, :server_secret, :platform, :req_sig_method, :resp_sig_method, presence: true
  
  mount_uploader :icon, AvatarUploader
  
  scope :opened, -> { where(opened: true) }
  scope :sorted, -> { order('sort asc') }
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..6]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
end
