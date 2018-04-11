class RedbagPrize < ActiveRecord::Base
  belongs_to :redbag
  
  validates :name, presence: true
end
