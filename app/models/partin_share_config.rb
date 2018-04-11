class PartinShareConfig < ActiveRecord::Base
  belongs_to :winnable, polymorphic: true
  belongs_to :partin
  
  mount_uploader :icon, AvatarUploader
end
