class CashRedbagSendLog < ActiveRecord::Base
  belongs_to :user, foreign_key: 'to_user_id'
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :send_cash_redbag
  def send_cash_redbag
    CashRedbagSendJob.perform_later(self.id)
  end
end
