class Attachment < ActiveRecord::Base
  belongs_to :attachmentable, polymorphic: true
  belongs_to :ownerable, polymorphic: true
  
  mount_uploader :data, AttachmentUploader, :mount_on => :data_file_name
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      self.uniq_id = SecureRandom.hex(10)
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  # after_create :update_file_info
  # def update_file_info
  #   self.data_file_size = data.size
  #   self.data_content_type = data.content_type
  #   self.width = data.try(:width)
  #   self.height = data.try(:height)
  #   self.save!
  # end
  
end
