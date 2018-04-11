class Wechat::PortalController < Wechat::ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:message, :pay_notify]
  skip_before_filter :check_weixin_legality, except: [:message]
  def echo
    render text: params[:echostr]
  end
  
  def message
    if weixin_xml.event == 'subscribe' or weixin_xml.event == 'SCAN'
      # 初次关注，注册用户
      signup_user weixin_xml
      
      if weixin_xml.event == 'subscribe'
        # 初次关注，发送欢迎消息
        if CommonConfig.wx_welcome_tpl# && code.code
          # @msg = "#{CommonConfig.wx_welcome_tpl.gsub('#code#', code.code)}"
          @msg = CommonConfig.wx_welcome_tpl.gsub("\\n", "\n")
        end
      end
      
      # 优惠卡验证或用户消费验证
      if weixin_xml.event_key
        if weixin_xml.event_key.starts_with?('uc:') # 商家验证用户的优惠卡
          _,code = weixin_xml.event_key.split(':')
      #     # puts code
          @msg = verify_user_card(weixin_xml.from_user, code)
          # @msg = " "
      #   elsif weixin_xml.event_key.starts_with?('up:') # 验证用户消费
      #     _,code = weixin_xml.event_key.split(':')
      #     # @msg = verify_user_pay(weixin_xml.from_user, code)
      #     @msg = " "
      #   elsif weixin_xml.event_key.starts_with?('uspr:') # 分享海报红包参与
      #     # puts code
      #     _,code = weixin_xml.event_key.split(':')
      #     # @msg = verify_user_share_poster_redbag(weixin_xml.from_user, code)
      #     # puts @msg
      #     @msg = " "
      #   elsif weixin_xml.event_key.starts_with?('bind:') # 分享海报红包参与
      #     _,code = weixin_xml.event_key.split(':')
      #     # @msg = verify_user_share_poster_redbag(weixin_xml.from_user, code)
      #     # puts @msg
      #     @msg = bind_wx_user_to_admin_user(weixin_xml.from_user, code)
      #     # @msg = " "
      #
        end
      end
      
      # 商家管理员绑定
      if weixin_xml.event_key.starts_with?('bind:')
        _,code = weixin_xml.event_key.split(':')
        @msg = bind_wx_user_to_admin_user(weixin_xml.from_user, code)
      end
      
    end
    
    # 上报用户的位置信息时，直接回复空消息给用户
    if weixin_xml.type == 'event' && weixin_xml.event == 'LOCATION'
      render text: ""
      return
    end
    
    # 获取客服消息
    if weixin_xml.event == 'CLICK' && weixin_xml.event_key == 'kefu_01'
      @msg = CommonConfig.wx_kefu_tip.gsub("\\n", "\n")
    end
    
    # 绑定微信
    if weixin_xml.event == 'CLICK' && weixin_xml.event_key == 'bind_wx'
      wp = WechatProfile.find_by(openid: weixin_xml.from_user)
      if wp.bind_at.present?
        @msg = "您已经绑定过微信了"
      else
        wp.generate_code!
        @msg = "验证码是：#{wp.code}"
      end
    end
    
    # 收到用户发来的消息，通知管理员
    if weixin_xml.type != 'event'
      notify_backend_manager
    end
    
    # 发现金红包
    # if weixin_xml.type == 'text' && weixin_xml.content == CommonConfig.sign_answer
    #   profile = WechatProfile.find_by(openid: weixin_xml.from_user)
    #   if profile && profile.user
    #     SendCashRedbag.send(profile.user, weixin_xml.content, request.remote_ip)
    #   end
    # end
    
    # 记录最新取关时间
    if weixin_xml.event == 'unsubscribe'
      profile = WechatProfile.find_by(openid: weixin_xml.from_user)
      if profile
        profile.unsubscribe_time = Time.zone.now
        profile.save
        
        # 并通知后台管理员有人取消关注
        notify_backend_manager_for_user(profile.nickname, '取消关注')
        
      end
    end
    
    # 更新用户微信资料
    if weixin_xml.event != 'unsubscribe'
      update_user_profile_if_needed weixin_xml
    end
    
  end
  
  # 官方分享
  def share
    
  end
  
  # 活动分享
  def event_share
    
  end
  
  def pay_notify
    @output = {
      return_code: '',
      return_msg: 'OK',
    }
    
    result = params['xml']
    if result and result['return_code'] == 'SUCCESS' and Wechat::Pay.notify_verify?(result)
      # 修改充值状态
      order = Charge.find_by(uniq_id: result['out_trade_no'])
      if order.present? and order.not_payed?
        order.pay!
      end
      @output[:return_code] = 'SUCCESS'
    else
      # 支付失败
      @output[:return_code] = 'FAIL'
    end
    
    respond_to do |format|
      format.xml { render xml: @output.to_xml(root: 'xml', skip_instruct: true, dasherize: false) }
    end
  end
    
  def yujian
    
    redirect_to "#{SiteConfig.yj_portal_url}?t=#{Time.zone.now.to_i}"
  end
  
  # App微信授权登录
  def app_auth_redirect
    redirect_to("#{SiteConfig.wx_app_url}?code=#{params[:code]}")
  end
  
  def redirect_uri
    url = "#{params[:url]}?code=#{params[:code]}"
    redirect_to(url)
  end
  
  def entry_help
    
  end
  
  # QQ授权登录
  def qq_auth
    original_url = params[:url]
    # original_url = "#{wechat_share_event_url}?id=#{params[:eid]}&token=#{params[:token]}"
    
    if params[:code].blank?
      flash[:notice] = '取消登录认证'
      redirect_to(original_url)
      return
    end
    
    # 开始获取Token
    resp = RestClient.get "https://graph.qq.com/oauth2.0/token", 
                   { :params => { 
                                  :client_id      => SiteConfig.qq_app_id,
                                  :client_secret  => SiteConfig.qq_app_secret,
                                  :grant_type => "authorization_code",
                                  :code       => params[:code],
                                  :redirect_uri => "#{qq_auth_url}?url=#{original_url}"
                                } 
                   }
                 
    # result = JSON.parse(resp)
    access_token = nil
    
    arr = resp.to_s.split('&')
    arr.each do |item|
      if item.include?('access_token')
        _,access_token = item.split('=') 
        break
      end
    end
    
    if access_token.blank?
      flash[:notice] = '登录认证失败'
      redirect_to(original_url)
      return
    end
    
    puts access_token
    # https://graph.qq.com/oauth2.0/me?access_token=YOUR_ACCESS_TOKEN
    
    resp = RestClient.get "https://graph.qq.com/oauth2.0/me", 
                   { :params => { 
                                  :access_token   => access_token
                                } 
                   }
    
    # result2 = JSON.parse(resp)
    
    result = resp.to_s
    
    _,val = result.split('(')
    val,_ = val.split(')')
    
    result = JSON.parse(val)
    openid = result['openid']
    
    puts openid
    
    profile = QqProfile.find_by(openid: openid)
    if profile.blank?
      # 开始获取用户基本信息
      resp = RestClient.get "https://graph.qq.com/user/get_user_info", 
                     { :params => { 
                                    :access_token   => access_token,
                                    :oauth_consumer_key => SiteConfig.qq_app_id,
                                    :openid => openid
                                  } 
                     }
                     
      user_info_result = JSON.parse(resp)
      
      user = User.new
      profile = QqProfile.new(openid: openid,
                              nickname: user_info_result['nickname'],
                              sex: user_info_result['gender'],
                              language: user_info_result['language'],
                                  city: user_info_result['city'],
                                  province: user_info_result['province'],
                                  country: user_info_result['country'],
                                  headimgurl: user_info_result['figureurl_qq_2'],
                                  #subscribe_time: result['subscribe_time'],
                                  # unionid: user_info_result['unionid'],
                                  access_token: access_token,
                                  refresh_token: nil)
      user.qq_profile = profile
      user.save!
    else
      profile.access_token = access_token
      profile.refresh_token = nil#result['refresh_token']
      profile.save!
      
      user = profile.user
    end
    
    # 用户登录
    if user
      log_in(user)
      remember(user)
      
      if original_url.include?'?'
        url_str = "#{original_url}&f=#{user.private_token}"
      else
        url_str = "#{original_url}?f=#{user.private_token}"
      end
      redirect_to(url_str)
    else
      render text: 'QQ认证失败', status: 401
    end
    
  end
  
  # 微信授权登录
  def auth
    # if params[:is_hb]
    #   original_url = "#{wechat_share_redbag_url}?id=#{params[:eid]}&token=#{params[:token]}&is_hb=1"
    # else
    #   original_url = "#{wechat_share_event_url}?id=#{params[:eid]}&token=#{params[:token]}"
    # end
    
    original_url = params[:url]
    # original_url = "#{wechat_share_event_url}?id=#{params[:eid]}&token=#{params[:token]}"
    
    if params[:code].blank?
      flash[:notice] = '取消登录认证'
      redirect_to(original_url)
      return
    end

    # 开始获取Token
    resp = RestClient.get "https://api.weixin.qq.com/sns/oauth2/access_token", 
                   { :params => { 
                                  :appid      => SiteConfig.wx_app_id,
                                  :secret     => SiteConfig.wx_app_secret,
                                  :grant_type => "authorization_code",
                                  :code       => params[:code]
                                } 
                   }
                 
    result = JSON.parse(resp)
    
    openid = result['openid'];
    if openid.blank?
      flash[:error] = '无效的code，请重试'
      redirect_to(original_url)
      return 
    end
    
    profile = WechatProfile.find_by(openid: openid)
    if profile.blank?
      # 开始获取用户基本信息
      user_info = RestClient.get "https://api.weixin.qq.com/sns/userinfo", 
                     { :params => { 
                                    :access_token => result['access_token'],
                                    :openid       => openid,
                                    :lang         => "zh_CN",
                                  } 
                     }
      user_info_result = JSON.parse(user_info)
      
      user = User.new
      profile = WechatProfile.new(openid: openid,
                                  nickname: user_info_result['nickname'],
                                  sex: user_info_result['sex'],
                                  language: user_info_result['language'],
                                  city: user_info_result['city'],
                                  province: user_info_result['province'],
                                  country: user_info_result['country'],
                                  headimgurl: user_info_result['headimgurl'],
                                  #subscribe_time: result['subscribe_time'],
                                  unionid: user_info_result['unionid'],
                                  access_token: result['access_token'],
                                  refresh_token: result['refresh_token'])
      user.wechat_profile = profile
      user.save!
    else
      profile.access_token = result['access_token']
      profile.refresh_token = result['refresh_token']
      profile.save!
      
      user = profile.user
    end
    
    # 用户登录
    log_in(user)
    remember(user)
    # session['auth.flag'] = 1
    
    # if params[:is_hb]
    #   redirect_to("#{wechat_share_redbag_url}?id=#{params[:eid]}&token=#{user.private_token}&is_hb=1")
    # else
    #   redirect_to("#{wechat_share_event_url}?id=#{params[:eid]}&token=#{user.private_token}")
    # end
    if original_url.include? '?'
      url_str = "#{original_url}&f=#{user.private_token}"
    else
      url_str = "#{original_url}?f=#{user.private_token}"
    end
    redirect_to(url_str)
    
  end
  
  private 
  def signup_user(wx_params)
    profile = WechatProfile.find_by(openid: wx_params.from_user)
    if profile.blank?
      profile = WechatProfile.new(openid: wx_params.from_user)
      profile.subscribe_time = Time.zone.now.to_i.to_s
      # user = User.new
      # user.wechat_profile = profile
      # user.save!
      profile.save!
      
      # 统计用户的来源
      # if wx_params.event_key
      #   code = wx_params.event_key.split('_').last
      #   user_channel = UserChannel.find_by(uniq_id: code)
      #   if user_channel
      #     UserChannelLog.create(user_id: user.id, user_channel_id: user_channel.id)
      #   end
      # end
      
      # 通知管理员有新用户关注并注册
      notify_backend_manager_for_user(profile.nickname, '关注')
    else
      if profile.subscribe_time.blank?
        profile.subscribe_time = Time.zone.now.to_i.to_s
        profile.save!
        
        notify_backend_manager_for_user(profile.nickname, '关注')
      end
    end
    
    # 创建用户组并将用户加入组
    if wx_params.event_key
      code = wx_params.event_key.split('_').last
      # user_channel = UserChannel.find_by(uniq_id: code)
      if code && profile.openid
        Wechat::Base.add_users_to_group([profile.openid],Wechat::Base.create_user_group(code.to_s))
      end
    end
    
  end
  
  def verify_user_card(openid, code)
    @user_card = UserCard.find_by(uniq_id: code)
    if @user_card.blank?
      return "操作失败，不存在的卡！"
    end

    # 商家
    wp = WechatProfile.find_by(openid: openid)
    if wp.blank?
      return '操作失败，您还未关注'
    end
    
    au = AdminUser.where(wx_user_id: wp.id).first
    if au.blank?
      au = AdminUser.where(wx_user_id: wp.user.try(:id)).first
    end
    
    if au.blank?
      return '操作失败，您的账号还未绑定'
    end
    
    # user = User.joins(:wechat_profile).where(wechat_profiles: { openid: openid }).first
    # if user.blank?
    #   return "操作失败，您还未关注或还未注册"
    # end

    # if not user.verified
    #   return "操作失败，您的账号已经被禁用了"
    # end
    merchant = au.merchant
    if merchant.blank?
      return '操作失败，无效的商家登录账号'
    end

    return @user_card.verify_consume_for(merchant)
  end
  
  def verify_user_pay(openid, code)
    @user_pay = UserPay.find_by(uniq_id: code)
    if @user_pay.blank?
      return "操作失败，不存在的抵扣申请！"
    end

    # 商家
    user = User.joins(:wechat_profile).where(wechat_profiles: { openid: openid }).first
    if user.blank?
      return "操作失败，您还未关注或还未注册"
    end

    if not user.verified
      return "操作失败，您的账号已经被禁用了"
    end

    return @user_pay.verify_consume_for(user)
  end
  
  def verify_user_share_poster_redbag(openid, code)
    @user_poster_redbag = UserPosterRedbag.find_by(uniq_id: code)
    if @user_poster_redbag.blank?
      return "操作失败，不存在的分享红包！"
    end
    
    # 商家
    user = User.joins(:wechat_profile).where(wechat_profiles: { openid: openid }).first
    if user.blank?
      return "操作失败，您还未关注或还未注册"
    end
    
    if not user.verified
      return "操作失败，您的账号已经被禁用了"
    end
    
    return @user_poster_redbag.commit_redbag_for(user, request.remote_ip)
  end
  
  def bind_wx_user_to_admin_user(openid, code)
    # user = User.joins(:wechat_profile).where(wechat_profiles: { openid: openid }).first
    # if user.blank?
    #   return "操作失败，您还未关注或还未注册"
    # end
    wp = WechatProfile.find_by(openid: openid)
    if wp.blank? 
      return "操作失败，您还未关注!"
    end
    
    admin_user = AdminUser.find_by(email: code)
    if admin_user.blank?
      return "操作失败，未找到该登录账号"
    end
    
    if admin_user.wx_user_id.blank?
      admin_user.wx_user_id = wp.user_id || wp.id
      admin_user.save!
    
      return "操作成功，成功绑定了微信"
    else
      return "操作失败，当前账号已经绑定过微信，需要先解绑"
    end
  end
  
  def notify_backend_manager_for_user(nickname, action)
    if action == '关注'
      msg = nickname.blank? ? "有新用户关注" : "有新用户[#{nickname}]关注"
    elsif action == '取消关注'
      msg = "有用户[#{nickname}]取消关注公众号"
    else
      return
    end
    
    payload = {
      first: {
        value: "#{msg}\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "用户操作提醒",
        color: "#173177",
      },
      keyword2: {
        value: "#{Time.zone.now.strftime('%Y年%m月%d日 %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "请留意用户的变化",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    
    Message.create!(message_template_id: 6, content: payload,link: SiteConfig.wx_app_url, to_users: user_ids)
  end
  
  def notify_backend_manager
    profile = WechatProfile.find_by(openid: weixin_xml.from_user)
    return if profile.blank?
    
    msg = "收到了来自用户(#{profile.nickname})的公众号消息"
    @sent_count = Message.joins(:message_template).where(message_templates: { title: '监控预警提醒' }).where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).where('content like ?', '%' + msg + '%').count
    if @sent_count > 0
      return
    end
    
    payload = {
      first: {
        value: "#{msg}\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "消息提醒",
        color: "#173177",
      },
      keyword2: {
        value: "#{Time.zone.now.strftime('%Y年%m月%d日 %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "请尽快回复用户的消息~",
        color: "#173177",
      }
    }.to_json
    
    user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    
    Message.create!(message_template_id: 6, content: payload,link: SiteConfig.wx_app_url, to_users: user_ids)
  end
  
  def update_user_profile_if_needed(wx_params)
    profile = WechatProfile.find_by(openid: wx_params.from_user)
    if profile #&& (profile.nickname.blank? or profile.headimgurl.blank?)
      ak = Wechat::Base.fetch_access_token
      result = Wechat::Base.fetch_user_base_info(ak, profile.openid)
      return if result.blank?
      
      need_update = false
      # 修改昵称
      if result['nickname'] && result['nickname'] != profile.nickname
        profile.nickname = result['nickname']
        need_update = true
      end
      
      # 修改头像
      if result['headimgurl'] && result['headimgurl'] != profile.headimgurl
        profile.headimgurl = result['headimgurl']
        need_update = true
      end
      
      if result['subscribe_time'] && result['subscribe_time'] != profile.subscribe_time
        profile.subscribe_time = result['subscribe_time']
        need_update = true
      end
      
      profile.sex = result['sex']
      profile.language = result['language']
      profile.city = result['city']
      profile.province = result['province']
      profile.country = result['country']
      profile.unionid = result['unionid']
      
      if need_update
        profile.save
      end
      
    end # end if
  end # end method
end
