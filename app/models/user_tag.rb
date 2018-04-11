class UserTag < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag, class_name: 'MerchantTag', foreign_key: 'tag_id'
end
