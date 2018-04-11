class Follow < ActiveRecord::Base
  validates :user_id, :merchant_id, presence: true
  belongs_to :user
  belongs_to :merchant, counter_cache: true
end
