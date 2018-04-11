class Message < ActiveRecord::Base
  belongs_to :message_template
  validates :content, :message_template_id, presence: true
  
  after_create :push_message
  def push_message
    if to_users.any?
      @user_ids = to_users
    else
      @user_ids = User.where(verified: true).pluck(:id).to_a
    end
    @user_ids.each do |uid|
      WechatMessageSendJob.perform_later(uid, self.message_template.tpl_id, self.link, JSON.parse(self.content)) if self.message_template
    end
  end
  
  before_save :remove_blank_value_for_array
  def remove_blank_value_for_array
    self.to_users = self.to_users.compact.reject(&:blank?)
  end
  
end
