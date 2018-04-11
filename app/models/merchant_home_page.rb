class MerchantHomePage < ActiveRecord::Base
  validates :title, :body, presence: true
  mount_uploaders :images, ImagesUploader
  
  scope :opened, -> { where(opened: true) }
  scope :sorted, -> { order('sort asc') }
  
  before_create :generate_oid
  def generate_oid
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.oid = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:oid => oid)
  end
  
  def owner
    Merchant.find_by(merch_id: merchant_id)
  end
  
  def add_hits
    self.class.increment_counter(:hits, self.id)
  end
  
end
