class AppVersion < ActiveRecord::Base
  validates :version, :os, :change_log, presence: true
  
  mount_uploader :app_file, AppFileUploader
  
  # validate :require_app_file, on: :create
  # def require_app_file
  #   if app_file.blank? or app_download_url.blank?
  #     errors.add(:base, 'App安装包或下载地址必须指定一个')
  #     return false
  #   end
  # end
  
  def app_url
    if self.app_download_url.blank?
      self.app_file.try(:url) || ''
    else
      self.app_download_url
    end
    # if self.app_file.blank?
    #   self.app_download_url
    # else
    #   self.app_file.url
    # end
  end
  
  def app_file_url
    # return '' if self.app_file.blank?
    # origin_file_url = SiteConfig.qiniu_bucket_domain + "/uploads/app_file/" + self.app_file
    # Qiniu::Auth.authorize_download_url(self.app_download_url)
  end
  
end
