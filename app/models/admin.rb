class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable
  
  # 超级管理员
  def super_admin?
    Setting.admin_emails.include?(self.email)
  end
  
  # 管理员
  def admin?
    super_admin? || self.role.to_sym == :admin
  end
  
  # 站点编辑人员
  def site_editor?
    admin? || self.role.to_sym == :site_editor
  end
  
  # 市场人员
  def marketer?
    admin? || self.role.to_sym == :marketer
  end
  
  # 限制使用人员
  def limited_user?
    admin? || self.role.to_sym == :limited_user
  end
  
  def self.roles
    if SiteConfig.roles
      SiteConfig.roles.split(',')
    else
      []
    end
  end
  
  def format_avatar_url
    CommonConfig.offical_app_icon || ''
  end
  
  def format_nickname
    '惠互动官方'
  end
  
  def role_name
    return '管理员' if super_admin?
    return '' if role.blank?
    I18n.t("common.#{role}")
  end
  
  # def roles?(role)
  #   role_sym = role.to_sym
  #   case role_sym
  #   when :super_admin then super_admin?
  #   when :admin then admin?
  #   when :site_editor then site_editor?
  #   when :marketer then marketer?
  #   else false
  #   end
  # end
  
end
