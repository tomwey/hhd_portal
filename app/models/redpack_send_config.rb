class RedpackSendConfig < ActiveRecord::Base
  belongs_to :redpack
  
  validates :send_name, :wishing, presence: true
end
