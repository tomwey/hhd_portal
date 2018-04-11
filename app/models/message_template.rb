class MessageTemplate < ActiveRecord::Base
  validates :tpl_id, :title, presence: true
end
