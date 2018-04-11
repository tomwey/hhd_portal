class Recharge < ActiveRecord::Base
  belongs_to :merchant
  
  validates :s_money, :money, :merchant_id, presence: true
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :write_pay_log
  def write_pay_log
    # Recharge.transaction do
    PayLog.create!(money: self.money, merchant: merchant, payable: self, title: '充值')
    # end
  end
  
  def s_money=(val)
    self.money = val.to_f * 100
  end
  
  def s_money
    return nil if self.money.blank?
    self.money / 100.0
  end
  
end
