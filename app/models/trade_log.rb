class TradeLog < ActiveRecord::Base
  validates :user_id, :money, presence: true
  belongs_to :tradeable, polymorphic: true
  belongs_to :user
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def format_money
    if self.tradeable_type == 'Hongbao' or 
      self.tradeable_type == 'Charge' or 
      self.tradeable_type == 'RedbagEarnLog' or 
      self.tradeable_type == 'RedbagShareEarnLog' or 
      self.tradeable_type == 'OfferwallChannelCallback' or
      self.tradeable_type == 'UserRedpack'
      
      "+#{self.money.blank? ? '0.00' : ('%.2f' % self.money)}"
    else
      "-#{self.money.blank? ? '0.00' : ('%.2f' % self.money)}"
    end
  end
  
  def redbag_info
    redbag = tradeable.try(:redbag)
    if redbag.blank?
      self.title
    else
      I18n.t("common.redbag.use_type_#{redbag.use_type}")
    end
  end
end
