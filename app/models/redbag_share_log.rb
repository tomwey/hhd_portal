class RedbagShareLog < ActiveRecord::Base
  belongs_to :redbag
  belongs_to :user
  
  after_create :add_share_count
  def add_share_count
    redbag.add_share_count
  end
  
  def group_by_date
    created_at.to_date.to_s(:db)
  end
end
