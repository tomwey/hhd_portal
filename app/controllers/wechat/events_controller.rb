class Wechat::EventsController < Wechat::ApplicationController
  layout 'share'
  skip_before_filter :check_weixin_legality
  
  # before_filter :require_user, only: [:portal, :wallet]
  
  def share
    @event_portal = "#{SiteConfig.hhd_event_portal}/wx/event/portal?" + request.query_string
    #
    # request.headers['foo'] = 'bar'
    # url = request.original_url#"#{SiteConfig.hhd_event_portal}/wx/event/portal?" + request.original_url.split('?').last
    #
    # redirect_url  = "#{SiteConfig.wx_auth_redirect_uri}?url=#{url}"#"#{wechat_auth_redirect_url}?url=#{request.original_url}"
    #
    # @wechat_auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{SiteConfig.wx_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&response_type=code&scope=snsapi_userinfo&state=yujian#wechat_redirect"
    # redirect_to @event_portal
  end
  
  def wallet
    if request.query_string.present?
      @event_wallet = "#{SiteConfig.hhd_event_portal}/wx/wallet?" + request.query_string
    else
      @event_wallet = "#{SiteConfig.hhd_event_portal}/wx/wallet"
    end
  end
  
  def wallet_result
    if request.query_string.present?
      @event_wallet_res = "#{SiteConfig.hhd_event_portal}/wx/wallet/result?" + request.query_string
    else
      @event_wallet_res = "#{SiteConfig.hhd_event_portal}/wx/wallet/result"
    end
  end
  
  def result
    if request.query_string.present?
      @event_result = "#{SiteConfig.hhd_event_portal}/wx/event/result?" + request.query_string
    else
      @event_result = "#{SiteConfig.hhd_event_portal}/wx/event/result"
    end
  end
  
end
