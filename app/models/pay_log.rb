class PayLog < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :payable, polymorphic: true
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :change_merchant_balance
  def change_merchant_balance
    merchant.balance += self.money
    merchant.save!
  end
  
end
