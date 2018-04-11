class Wechat::EventsController < Wechat::ApplicationController
  layout 'share'
  skip_before_filter :check_weixin_legality
  
  before_filter :require_user, only: [:portal, :wallet]
  
  # 真正的活动落地内容页面
  def portal
    # puts request.url
    puts request.referer
    
    @partin = Partin.find_by(uniq_id: params[:id])
    if @partin.blank?
      render text: '活动不存在'
      return 
    end
    
    @is_view = (params[:view] && params[:view].to_i == 1)
    
    if !@is_view
      if not @partin.opened
        render text: '活动还未上线'
        return
      end
    end
    
    if current_user.taked?(@partin)
      # 只能分享
      @has_taked = true
    else
      # 参与或者分享
      @has_taked = false
    end

    if @partin.partin_share_config
      @share_title = @partin.partin_share_config.title
      @share_image_url = @partin.partin_share_config.icon.url(:big)
    else
      if @partin.info_item
        @share_title = @partin.info_item.title
      else
        @share_title = '我正在玩“惠互动”，一个可以赚钱的平台，邀请您一起来玩'
      end
      @share_image_url = @partin.merchant.logo.url(:large)
    end
    
    @share_url = "#{SiteConfig.hhd_share_portal}/wx/event?" + request.query_string
    
    @sign_package = Wechat::Sign.sign_package(request.original_url)
    
    # @i = Time.zone.now.to_i.to_s + SecureRandom.random_number.to_s[2..7]
    # @ak = Digest::MD5.hexdigest(SiteConfig.api_key + @i)
  end
  
  def share
    @event_portal = "#{SiteConfig.hhd_event_portal}/wx/event/portal?" + request.query_string
    
    request.headers['foo'] = 'bar'
    # url = request.original_url#"#{SiteConfig.hhd_event_portal}/wx/event/portal?" + request.original_url.split('?').last
    #
    # redirect_url  = "#{SiteConfig.wx_auth_redirect_uri}?url=#{url}"#"#{wechat_auth_redirect_url}?url=#{request.original_url}"
    #
    # @wechat_auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{SiteConfig.wx_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&response_type=code&scope=snsapi_userinfo&state=yujian#wechat_redirect"
    redirect_to @event_portal
  end
  
  # 活动参与结果
  def result
    @partin = Partin.find_by(uniq_id: params[:id])
    if @partin.blank?
      render text: '没有找到活动'
      return 
    end
    
    @token = params[:token]
    
    @log = nil
    
    code = params[:code].to_i
    if code == 0
      @log = PartinTakeLog.find_by(uniq_id: params[:log_id])
      if @log
        if @log.resultable_type == 'UserRedpack'
          @resultDesc = '恭喜您获得了一个红包'
        elsif @log.resultable_type == 'UserCard'
          @resultDesc = '恭喜您获得了一张优惠卡'
        else
          @resultDesc = ''
        end
      end
    elsif code == 1
      @resultDesc = params[:message]
    else
      @resultDesc = 'Oops, 服务器出错了, 我们正在处理...'
    end
    
  end
  
  # 钱包提现
  def wallet
    @withdraw = Withdraw.where('account_no != account_name and user_id = ?', current_user.id).order('id desc').first
  end
  
  private
  def require_user
    # puts request.user_agent
    # puts '-----------------'
    # puts request.browser
    # puts request.from_pc?
    
    if current_user.blank?
      
      ua = request.user_agent
      is_wx_browser = ua.include?('MicroMessenger') || ua.include?('webbrowser')
      
      if is_wx_browser
        # puts '是微信浏览器'
        url = request.original_url#"#{SiteConfig.hhd_event_portal}/wx/event/portal?" + request.original_url.split('?').last
        
        redirect_url  = "#{SiteConfig.wx_auth_redirect_uri}?url=#{url}"#"#{wechat_auth_redirect_url}?url=#{request.original_url}"
        
        @wx_auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{SiteConfig.wx_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&response_type=code&scope=snsapi_userinfo&state=yujian#wechat_redirect"
        redirect_to @wx_auth_url 
        return false
      else
        # puts '不是微信浏览器'
        # redirect_url  = "#{qq_auth_url}?url=#{request.original_url}"
        # # puts redirect_url
        # @qq_auth_url = "https://graph.qq.com/oauth2.0/authorize?response_type=code&client_id=#{SiteConfig.qq_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&scope=get_user_info"
        # # puts @qq_auth_url
        # redirect_to @qq_auth_url
        redirect_to "#{wechat_entry_help_url}"
      end
    end
    
  end
end
