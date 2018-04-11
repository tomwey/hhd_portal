class LuckyDrawItem < ActiveRecord::Base
  belongs_to :lucky_draw
  
  validates :name, :angle, :score, presence: true
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..9]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def add_sent_count
    self.class.increment_counter(:sent_count, self.id)
  end
  
end
