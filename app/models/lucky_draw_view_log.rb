class LuckyDrawViewLog < ActiveRecord::Base
  belongs_to :lucky_draw
  belongs_to :user
  
  after_create :add_view_count
  def add_view_count
    lucky_draw.add_view_count
  end
end
