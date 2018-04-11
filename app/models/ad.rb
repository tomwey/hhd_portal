class Ad < ActiveRecord::Base
  validates :file, :duration, presence: true
  
  mount_uploader :file, AdContentsUploader
  
  before_create :generate_unique_oid
  def generate_unique_oid
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.oid = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:oid => oid)
  end
end
