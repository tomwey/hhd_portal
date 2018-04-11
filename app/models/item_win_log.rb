class ItemWinLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  belongs_to :resultable, polymorphic: true
  
  validates :user_id, :item_id, presence: true
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def result
    if resultable_type == 'RedbagEarnLog'
      money = resultable.try(:money)
      money.blank? ? 0.00 : ('%.2f' % money)
    elsif resultable_type == 'UserCard'
      resultable.try(:title)
    else
      ''
    end
  end
end
