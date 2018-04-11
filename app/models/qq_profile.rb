class QqProfile < ActiveRecord::Base
  belongs_to :user
  validates :openid, presence: true
end
