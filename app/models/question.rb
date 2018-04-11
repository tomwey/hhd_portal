class Question < ActiveRecord::Base
  validates :question, :answer, presence: true
  
  validate :answers_not_empty
  def answers_not_empty
    if answers.empty?
      errors.add(:base, '题目答案选项不能为空')
    end
  end
  
  def answers_str=(val)
    if val.present?
      self.answers = val.split(',')
    end
  end
  
  def format_type_name
    "[题目规则]#{question}"
  end
  
  def answers_str
    self.answers.join(',')
  end
  
  def verify(hash_data)
    if hash_data.blank? or hash_data[:answer].blank?
      return { code: -1, message: '参数不能为空，或者答案不能为空' }
    end
    
    if hash_data[:answer].to_s == self.answer.to_s
      return { code: 0, message: 'ok' }
    end
    
    return { code: 6003, message: '问题答错了，再接再厉哦~' }
  end
  
end
