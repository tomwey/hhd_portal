class RedbagViewLog < ActiveRecord::Base
  belongs_to :redbag
  belongs_to :user
  
  after_create :add_view_count
  def add_view_count
    redbag.add_view_count
  end
  
  def group_by_date
    created_at.to_date.to_s(:db)
  end
  
end
