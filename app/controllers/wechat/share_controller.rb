class Wechat::ShareController < Wechat::ApplicationController
  layout 'share'
  skip_before_filter :check_weixin_legality
  
  before_filter :require_user, only: [:partin, :redbag, :wallet]
  
  # 官方分享
  # http://domain/wx/share/offical?token=xxxxxxx
  def offical
    @users = User.includes(:wechat_profile).where('earn > 0').order('earn desc').limit(3)
    @earn_logs = EventEarnLog.joins(:user, :event).order('id desc').limit(10)
  end
  
  # 红包分享结果
  def result
    @redbag = Redbag.find_by(uniq_id: params[:id])
    if @redbag.blank?
      render text: '未找到红包'
      return 
    end
    
    if params[:money]
      @money = params[:money]
    else
      code = (params[:code] || 0)
      if code == 500
        @msg = '服务器出错，请稍后再试！'
      else
        @msg = params[:message]
      end
    end
    
    @total_money ||= Redbag.opened.no_complete.where(use_type: Redbag::USE_TYPE_EVENT).sum('total_money').to_i
    
  end
  
  # 晒提现
  def invite
    @share_title = ''
    @share_image_url = ''
    @share_desc = ''
    @sign_package = Wechat::Sign.sign_package(request.original_url)
  end
  
  # 广告参与结果
  def partin_result
    @partin = Partin.find_by(uniq_id: params[:id])
    if @partin.blank?
      render text: '没有找到数据'
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
  
  # 红包分享
  def partin
    # puts request.url
    
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
    
    @sign_package = Wechat::Sign.sign_package(request.original_url)
    
    # @i = Time.zone.now.to_i.to_s + SecureRandom.random_number.to_s[2..7]
    # @ak = Digest::MD5.hexdigest(SiteConfig.api_key + @i)
  end
  
  # 红包分享
  def redbag
    @redbag = Redbag.find_by(uniq_id: params[:id])
    if @redbag.blank?
      render text: '未找到红包'
      return 
    end
    
    if not @redbag.opened
      render text: '红包未上架'
      return
    end
    
    # if @redbag.share_hb_id.blank?
    #   render text: '该红包没有分享红包'
    #   return
    # end
    
    # @earn_logs = RedbagEarnLog.joins(:user, :redbag).where(redbag_id: @redbag.id).where.not(money: 0.0).order('money desc, id desc').limit(10)
    
    # @user = User.find_by(private_token: params[:token])
    # if @user && @user.balance > 0
    #   @share_title = "我刚刚在惠互动领了#{@user.balance}元，爽翻..."
    # else
    #   @share_title = CommonConfig.share_title || ''
    # end
    @share_title = @redbag.real_share_title
    @share_image_url = @redbag.share_image_icon

    # 写浏览日志
    # RedbagViewLog.create!(redbag_id: @redbag.id, ip: request.remote_ip, user_id: @user.try(:id), location: nil)
    
    @sign_package = Wechat::Sign.sign_package(request.original_url)
    
    # redirect_url  = "#{wechat_auth_redirect_url}?eid=#{@redbag.uniq_id}&token=#{params[:token]}&is_hb=1"
    # redirect_url  = "#{wechat_auth_redirect_url}?url=#{request.original_url}"
    #
    # @wx_auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{SiteConfig.wx_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&response_type=code&scope=snsapi_userinfo&state=yujian#wechat_redirect"
    #
    # # 表示用户认证登录通过，并注册了新的账号，然后重定向了当前路由，这个时候需要把这个token保存到localStorage
    # if session['auth.flag'] && session['auth.flag'].to_i == 1
    #   if @user
    #     session['auth.flag'] = nil
    #     @current_token = @user.private_token
    #   end
    # end
    #
    # @i = Time.zone.now.to_i.to_s + SecureRandom.random_number.to_s[2..7]
    # @ak = Digest::MD5.hexdigest(SiteConfig.api_key + @i)
    
  end
  
  # 简单的分享广告内容到
  def redbag2
    @redbag = Redbag.find_by(uniq_id: params[:id])
    if @redbag.blank?
      render text: '未找到红包'
      return 
    end
    
    # @user = User.find_by(private_token: params[:token])
    # if @user && @user.balance > 0
    #   @share_title = "我刚刚在惠互动领了#{@user.balance}元，爽翻..."
    # else
    #   @share_title = CommonConfig.share_title || ''
    # end
    @share_title = @redbag.title
    # puts @share_title
    @share_image_url = @redbag.share_image_icon

    @sign_package = Wechat::Sign.sign_package(request.original_url)
    
    @i = Time.zone.now.to_i.to_s
    @ak = Digest::MD5.hexdigest(SiteConfig.api_key + @i)
        
  end
  
  # 活动分享
  # http://domain/wx/share/event?id=123&token=xxxxx
  def event
    @event = Event.find_by(uniq_id: params[:event_id] || params[:id])
    if @event.blank?
      render text: '未找到该活动'
      return 
    end
    @earn_logs = EventEarnLog.joins(:user, :event).where(event_id: @event.id, hb_id: @event.current_hb.uniq_id).where.not(money: 0.0).order('id desc').limit(10)
    
    @user = User.find_by(private_token: params[:token])
    if @user && @user.balance > 0
      @share_title = "我刚刚在惠互动领了#{@user.balance}元，爽翻..."
    else
      @share_title = CommonConfig.share_title || ''
    end
    
    @has_share_hb = @event.share_hb && @event.share_hb.left_money > 0.0
    
    # 写浏览日志
    EventViewLog.create!(event_id: @event.id, ip: request.remote_ip, user_id: @user.try(:uid), location: nil)
    
    @sign_package = Wechat::Sign.sign_package(request.original_url)
    
    redirect_url  = "#{wechat_auth_redirect_url}?eid=#{@event.uniq_id}&token=#{params[:token]}"
    
    @wx_auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{SiteConfig.wx_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&response_type=code&scope=snsapi_userinfo&state=yujian#wechat_redirect"
    
    # 表示用户认证登录通过，并注册了新的账号，然后重定向了当前路由，这个时候需要把这个token保存到localStorage
    if session['auth.flag'] && session['auth.flag'].to_i == 1
      if @user
        session['auth.flag'] = nil
        @current_token = @user.private_token
      end
    end
    
    @i = Time.zone.now.to_i.to_s
    @ak = Digest::MD5.hexdigest(SiteConfig.api_key + @i)
    
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
        
        redirect_url  = "#{SiteConfig.wx_auth_redirect_uri}?url=#{request.original_url}"#"#{wechat_auth_redirect_url}?url=#{request.original_url}"
        
        # puts redirect_url

        @wx_auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{SiteConfig.wx_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&response_type=code&scope=snsapi_userinfo&state=yujian#wechat_redirect"
        redirect_to @wx_auth_url 
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
    # @user = User.find_by(private_token: params[:token])
    # if @user.blank?
    #   render text: '非法访问'
    #   return false
    # end
  end
end
