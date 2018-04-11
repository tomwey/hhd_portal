require 'open-uri'
class App::HomeController < App::ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  
  def download
    bundle_id = params[:b]
    
    if bundle_id.blank?
      @page = Page.find_by(slug: 'download_image')
      @page_title = @page.title
      
      bundle_id = 'com.kekestudio.smallbest'
    else
      # @page = Page.find_by(slug: 'download_image')
      @page = Page.find_by(slug: 'jgmj_download')
      @page_title = @page.title
      
      if not bundle_id.include?('.')
        bundle_id = "com.kekestudio.#{bundle_id}"
      end
      
    end
    
    # puts request.user_agent       #=> "Mozilla/5.0 (Macintosh; ..."
    # puts request.device_type      #=> :pc
    # puts request.os               #=> "Mac OSX"
    # puts request.browser          #=> "Chrome"
    # puts request.from_pc?         #=> true
    # puts request.from_smartphone? #=> false
    
    if request.from_smartphone?
      if request.os == 'Android'
        # version = AppVersion.where('lower(os) = ?', 'android').where(opened: true).order('version desc').first
        # if version.blank?
        #   @app_url = "#{app_download_url}"
        # else
        #   @app_url = version.app_url
        # end
        # puts version
        @app_url = "#{app_install_url}?b=#{bundle_id}"
      elsif request.os == 'iPhone'
        if bundle_id.blank?
          @app_url = 'https://itunes.apple.com/us/app/%E5%B0%8F%E4%BC%98%E5%A4%A7%E6%83%A0/id1308830536?ls=1&mt=8'
        else
          version = AppVersion.where('lower(os) = ?', 'ios').where(opened: true).where(bundle_id: bundle_id).order('version desc').first
          @app_url = version.try(:app_url) || "#{app_download_url}?b=#{bundle_id}"
        end
      else
        @app_url = "#{app_download_url}?b=#{bundle_id}"
      end
    else
      @app_url = "#{app_download_url}?b=#{bundle_id}"
    end
    
    # @app_url = "#{app_install_url}"
    
    # puts @app_url
  end
  
  # def download2
  #   ua = request.user_agent
  #   is_wx_browser = ua.include?('MicroMessenger') || ua.include?('webbrowser')
  #
  #   if is_wx_browser
  #     # render :hack_download
  #     File.open("#{Rails.root}/config/file.ipa", 'r') do |f|
  #       send_data f.read, disposition: 'attachment', filename: 'file.ipa'
  #     end
  #   else
  #     if request.from_smartphone? and request.os == 'Android'
  #       version = AppVersion.where('lower(os) = ?', 'android').where(opened: true).order('version desc').first
  #       redirect_to version.app_url || 'http://hb.small-best.com'
  #     else
  #       redirect_to 'http://hb.small-best.com'
  #     end
  #   end
  #
  # end
  
  # def hack_download
  #   # send_file "#{Rails.root}/config/hack.doc", filename: 'hack.doc', disposition: 'attachment', stream: 'true'
  #   # data = open("http://0.0.0.0:3000/hack.doc")
  #   File.open("#{Rails.root}/config/file.ipa", 'r') do |f|
  #     send_data f.read, disposition: 'attachment', filename: 'hack.doc'
  #   end
  # end
  
  def install
    
    bundle_id = params[:b]
    
    if bundle_id.blank?
      bundle_id = 'com.kekestudio.smallbest'
    else
      if not bundle_id.include?('.')
        bundle_id = 'com.kekestudio.' + bundle_id
      end
    end
    
    ua = request.user_agent
    is_wx_browser = ua.include?('MicroMessenger') || ua.include?('webbrowser')
    
    if is_wx_browser
      # render :hack_download
      File.open("#{Rails.root}/config/hack.doc", 'r') do |f|
        send_data f.read, disposition: 'attachment', filename: 'file.doc', stream: 'true'
      end
    else
      if request.from_smartphone? and request.os == 'Android'
        version = AppVersion.where('lower(os) = ?', 'android').where(opened: true, bundle_id: bundle_id).order('version desc').first
        redirect_to version.app_url || "#{app_download_url}"
      else
        redirect_to "#{app_download_url}"
      end
    end
    # version = AppVersion.where('lower(os) = ?', 'android').where(opened: true).order('version desc').first
    # if version.blank? or version.app_file.blank?
    #   @app_url = "#{app_download_url}"
    #   redirect_to @app_url
    # else
    #   @app_url = version.app_url
    #   data = open(@app_url)
    #   # send_data data, disposition: 'attachment', filename: "smallbest.apk"
    #   send_data data.read, filename: "com.kekestudio.smallbest_#{version.version}.apk",#File.basename(version.app_file.path),
    #     # type: "application/vnd.android.package-archive",
    #     disposition: 'attachment',
    #     stream: 'true',
    #     buffer_size: '4096'
    #   # send_file @app_url, filename: 'smallbest.apk', disposition: 'attachment'
    # end
  end
    
end
