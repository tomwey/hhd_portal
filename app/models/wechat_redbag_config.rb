class WechatRedbagConfig < ActiveRecord::Base
  belongs_to :redbag
  
  validates :send_name, :wishing, presence: true
  
  # before_destroy :change_redbag_to_no_cash
  # def change_redbag_to_no_cash
  #   redbag.is_cash_hb = false
  #   redbag.save!
  # end
  
end
