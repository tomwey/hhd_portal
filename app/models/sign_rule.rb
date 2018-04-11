class SignRule < ActiveRecord::Base
  validates :answer, :answer_from_tip, presence: true
  
  def uid=(val)
    self.user_id = User.find_by(uid: val).try(:id)
  end
  
  def uid
    User.find_by(id: self.user_id).try(:uid)
  end
  
  def sign_desc
    "#{answer_from_tip}:#{answer}"
  end
  
  def verify(hash_data)
    if hash_data.blank? or hash_data[:answer].blank?
      return { code: -1, message: '参数不能为空，或者答案不能为空' }
    end
    
    arr = self.answer.split(',')
    if arr.include?(hash_data[:answer])
      return { code: 0, message: 'ok' }
    end
    
    return { code: 6003, message: '口令不正确' }
  end
  
end
