class Merchant < ActiveRecord::Base
  validates :name, :mobile, presence: true
  validates :logo, presence: true, on: :create
  
  # has_and_belongs_to_many :users
  has_many :user_merchants
  has_many :users, through: :user_merchants
  
  mount_uploader :logo, AvatarUploader
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def tag_name=(val)
    if val.present?
      self.tags = val.split(',')
    end
  end
  
  def tag_name
    tags.join(',')
  end
  
  def s_balance=(val)
    if val.present?
      self.balance = val.to_f * 100
    end
  end
  
  def s_balance
    self.balance / 100.0
  end
  
end
