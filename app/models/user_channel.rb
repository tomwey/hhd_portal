class UserChannel < ActiveRecord::Base
  validates :name, presence: true
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
  
  after_create :generate_qrcode_ticket
  def generate_qrcode_ticket
    ticket = Wechat::Base.fetch_qrcode_ticket(self.uniq_id.to_s)
    if ticket
      self.qrcode_ticket = ticket
      self.save!
    end
  end
  
end
