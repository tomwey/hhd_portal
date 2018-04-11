class ItemShareLog < ActiveRecord::Base
  belongs_to :item
  
  belongs_to :user
  
  after_create :add_share_count
  def add_share_count
    item.add_share_count
  end
end
