class LuckyDrawPrizeLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :lucky_draw
  
  validates :user_id, :lucky_draw_id, :prize_id, presence: true
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :change_lucky_draw_stats
  def change_lucky_draw_stats
    lucky_draw.add_draw_count
    
    # item = LuckyDrawItem.find_by(id: prize_id)
    prize.add_sent_count unless prize.blank?
    
    user.add_prized_count!;
  end
  
  def prize
    LuckyDrawItem.find_by(id: prize_id)
  end
  
end
