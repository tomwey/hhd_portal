class ItemViewLog < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
  
  after_create :add_view_count
  def add_view_count
    item.add_view_count
  end
  
end
