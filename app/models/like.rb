class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true, counter_cache: true
  belongs_to :user
  
  validates :user_id, :likeable_type, :likeable_id, presence: true
end
