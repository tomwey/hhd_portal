ActiveAdmin.register_page "Dashboard" do

  menu priority: 0, label: proc{ I18n.t("active_admin.dashboard") }
  content title: '控制面板' do
    
    # 用户数据汇总
    columns do
      column do
        panel "用户数据汇总" do
          
          table class: 'stat-table' do
            tr do
              th '总商家数'
              th '总用户数'
              th '总关注用户'
              th '总取关用户'
              th '总使用次数'
            end
            tr do
              @total_merchant ||= Merchant.count
              @total_user ||= User.where(verified: true).count
              @total_follow_user ||= WechatProfile.where('subscribe_time is not null and unsubscribe_time is null').count
              @total_unfollow_user ||= WechatProfile.where('unsubscribe_time is not null').count
              @total_use_count ||= UserSession.count
              
              td @total_merchant
              td @total_user
              td @total_follow_user
              td @total_unfollow_user
              td @total_use_count
            end
          end # end table
          
          table class: 'stat-table' do
            tr do
              th '今日注册用户'
              th '今日关注用户'
              th '今日取关用户'
              th '今日使用次数'
              th '今日活跃用户'
            end
            tr do
              @today_user ||= User.where(verified: true, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              @today_follow_user ||= WechatProfile.where('subscribe_time is not null and unsubscribe_time is null')
                      .where(subscribe_time: Time.zone.now.beginning_of_day.to_i..Time.zone.now.end_of_day.to_i).count
              
              @today_unfollow_user ||= WechatProfile.where(unsubscribe_time: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              
              @today_use_count ||= UserSession.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              
              @today_access_user ||= UserSession.select('distinct user_id').where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
            
              td @today_user
              td @today_follow_user
              td @today_unfollow_user
              td @today_use_count
              td @today_access_user
            end
          end # end table
          
          # div do
          #   render 'user_sessions_graph'
          # end
          #
          # div do
          #   render 'user_graph'
          # end
          
        end
      end
    end
    
    columns do
      column do
        panel "广告数据汇总" do
          table class: 'stat-table' do
            tr do
              th '还剩广告个数'
              th '还剩红包金额'
              th '累计发广告个数'
              th '累计发广告金额'
              th '累计被抢金额'
              th '累计浏览次数'
              th '累计参与次数'
              th '累计转发次数'
            end
            
            tr do
              @left_count ||= Partin.opened.can_take.count
              @left_money ||= Redpack.where(in_use: true).where('total_money != sent_money').map { |o| o.left_money }.sum / 100.0
              # Partin.where(merchant_id: current_admin_user.merchant_id).opened.map { |o| o.winnable.try(:left_money) }.sum / 100.0
              
              @total_sent_count ||= Partin.opened.count
              @total_sent_money ||= Redpack.where(in_use: true).map { |o| o.total_money }.sum / 100.0
              # Partin.where(merchant_id: current_admin_user.merchant_id).opened.map { |o| o.winnable.try(:total_money) }.sum / 100.0
              
              @total_taked_money ||= PartinTakeLog.all.map { |o| (o.resultable.try(:money) || 0) }.sum / 100.0
              
              @total_view_count ||= PartinViewLog.count
              @total_take_count ||= PartinTakeLog.count
              @total_share_count ||= PartinShareLog.count
              
              td @left_count
              td @left_money
              td @total_sent_count
              td @total_sent_money
              td @total_taked_money
              td @total_view_count
              td @total_take_count
              td @total_share_count
            end
          end # end table
          
          table class: 'stat-table' do
            tr do
              th '今日发广告个数'
              th '今日发广告金额'
              th '今日被抢金额'
              th '今日浏览次数'
              th '今日参与次数'
              th '今日转发次数'
            end
            
            tr do
              @today_sent_count ||= Partin.opened.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              @today_sent_money ||= Redpack.where(in_use: true).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).map { |o| o.total_money }.sum / 100.0
              # Partin.where(merchant_id: current_admin_user.merchant_id).opened.map { |o| o.winnable.try(:total_money) }.sum / 100.0
              
              @today_taked_money ||= PartinTakeLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).map { |o| (o.resultable.try(:money) || 0) }.sum / 100.0
              
              @today_view_count ||= PartinViewLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              @today_take_count ||= PartinTakeLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              @today_share_count ||= PartinShareLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              
              td @today_sent_count
              td @today_sent_money
              td @today_taked_money
              td @today_view_count
              td @today_take_count
              td @today_share_count
            end
          end # end table
          
        end # end panel
      end # end column
    end # end
    
    # 红包数据汇总
    columns do
      column do
        panel "老数据汇总" do
          
          table class: 'stat-table' do
            tr do
              th '还剩红包个数'
              th '还剩红包金额'
              th '累计红包浏览次数'
              th '累计抢红包次数'
              th '累计被抢金额'
              th '累计发红包个数'
              th '累计发红包金额'
            end
            tr do
              # 剩余红包个数
              @left_hb_count ||= Redbag.opened.no_complete.not_share.count
              
              # 剩余红包金额
              @left_hb_money ||= Redbag.opened.no_complete.not_share.map { |hb| hb.left_money }.sum.to_f
              
              # 累计红包浏览次数
              @total_view_redbag ||= RedbagViewLog.count
              
              # 累计抢红包次数
              @total_redbag_earns ||= RedbagEarnLog.count
              
              # 累计被抢金额
              @total_redbag_money ||= RedbagEarnLog.joins(:redbag).where(redbags: { use_type: Redbag::USE_TYPE_EVENT }).sum(:money).to_f
              
              # 累计发红包个数
              @total_hb_count ||= Redbag.opened.not_share.count
              
              # 累计发红包金额
              @total_hb_money ||= Redbag.opened.not_share.pluck(:total_money).to_a.sum.to_f
              
              td @left_hb_count
              td @left_hb_money
              td @total_view_redbag
              td @total_redbag_earns
              td @total_redbag_money
              td @total_hb_count
              td @total_hb_money
            end
            
          end # end
          
          table class: 'stat-table' do
            tr do
              th '今日发红包个数'
              th '今日发红包金额'
              th '今日红包浏览次数'
              th '今日抢红包次数'
              th '今日抢红包金额'
              th '今日转发次数'
              th '累计转发次数'
            end
            tr do
              # 今日发红包个数
              @total_today_hb_count ||= Redbag.opened.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).not_share.count
              
              # 今日发红包金额
              @total_today_hb_money ||= Redbag.opened.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).not_share.pluck(:total_money).to_a.sum.to_f
              
              # 今日红包浏览次数
              @total_today_view_redbag ||= RedbagViewLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              
              # 今日抢红包次数
              @total_today_redbag_earns ||= RedbagEarnLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              
              # 今日抢红包金额
              @total_today_redbag_money ||= RedbagEarnLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:money).to_f
              
              # 今日转发次数
              @today_share_count ||= RedbagShareLog.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              
              # 累计转发次数
              @total_share_count ||= RedbagShareLog.count
              
              td @total_today_hb_count
              td @total_today_hb_money
              td @total_today_view_redbag
              td @total_today_redbag_earns
              td @total_today_redbag_money
              td @today_share_count
              td @total_share_count
            end
            
          end # end
          
          # render 'hb_graph'
          
        end # end panel
      end
    end
    
    # 用户排序
    columns do
      column do
        panel "最新注册的用户" do
          table_for User.where(verified: true).order("id desc").limit(20) do
            column('头像') { |o| image_tag o.real_avatar_url, size: '32x32' }
            column("昵称") { |o| link_to o.format_nickname, cpanel_user_path(o) }
            column('关注时间') { |o| o.wechat_profile.try(:subscribe_time).blank? ? '' : Time.at(o.wechat_profile.try(:subscribe_time).to_i).strftime('%Y年%m月%d日 %H:%M:%S') }
            column('取关时间') { |o| o.wechat_profile.try(:unsubscribe_time).blank? ? '' : o.wechat_profile.try(:unsubscribe_time).strftime('%Y年%m月%d日 %H:%M:%S') }
            column("注册时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M') }
          end
        end
      end
      
      column do
        panel "活跃用户排名" do
          table_for User.where(verified: true).where('use_sessions_count > 0').order('use_sessions_count desc').limit(20) do
            column('头像') { |o| image_tag o.real_avatar_url, size: '32x32' }
            column("昵称") { |o| link_to o.format_nickname, cpanel_user_path(o) }
            column("使用频次") { |o| o.use_sessions_count }
          end
        end
      end
    end
    
    # 用户会话图表
    # columns do
    #   column do
    #     panel "统计图表" do
    #       div do
    #         # @locations = WechatLocation.all
    #         render 'stat_graph'
    #       end
    #     end
    #   end
    # end
    
    # columns do
    #   column do
    #     @user_ids = RedbagEarnLog.joins(%Q|LEFT JOIN redbag_earn_logs as e on e.user_id = redbag_earn_logs.user_id and redbag_earn_logs.created_at < e.created_at|).where('e.created_at is null').where('redbag_earn_logs.created_at < ?', Time.zone.now - 3.days).order('redbag_earn_logs.created_at desc').pluck('redbag_earn_logs.user_id')
    #     @users ||= User.includes(:redbag_earn_logs, :wechat_profile).where(id: @user_ids).where.not(wechat_profiles: { subscribe_time: nil }).where(wechat_profiles: {unsubscribe_time: nil}).limit(20)
    #     render 'inactive_users', users: @users
    #   end
    # end
    
    # panel "超过3天未抢过红包的用户" do
    #   @user_ids = RedbagEarnLog.joins(%Q|LEFT JOIN redbag_earn_logs as e on e.user_id = redbag_earn_logs.user_id and redbag_earn_logs.created_at < e.created_at|).where('e.created_at is null').where('redbag_earn_logs.created_at < ?', Time.zone.now - 3.days).order('redbag_earn_logs.created_at desc').pluck('redbag_earn_logs.user_id') 
    #   #RedbagEarnLog.group(:id, :user_id).having('max(created_at) < ?', Time.zone.now - 3.days).pluck(:user_id).uniq
    #   table_for User.includes(:redbag_earn_logs, :wechat_profile).where(id: @user_ids) do
    #     column('头像') { |o| image_tag o.real_avatar_url, size: '32x32' }
    #     column("昵称") { |o| link_to o.format_nickname, cpanel_user_path(o) }
    #     column('关注时间') { |o| o.wechat_profile.try(:subscribe_time).blank? ? '' : Time.at(o.wechat_profile.subscribe_time.to_i).strftime('%Y年%m月%d日 %H:%M:%S') }
    #     column('取关时间') { |o| o.wechat_profile.try(:unsubscribe_time).blank? ? '' : o.wechat_profile.unsubscribe_time.strftime('%Y年%m月%d日 %H:%M:%S') }
    #     column('抢红包次数') { |o| o.redbag_earn_logs.count }
    #     column('抢红包总金额') { |o| o.redbag_earn_logs.sum(:money).to_f }
    #     column('距离上次抢红包的天数') { |o| ((Time.zone.now - o.redbag_earn_logs.order('id desc').first.created_at) / 86400).to_i }
    #     column("最近一次抢红包时间") { |o| o.redbag_earn_logs.order('id desc').first.created_at.strftime('%Y-%m-%d %H:%M') }
    #   end
    # end
    
    # 最新的抢红包记录
    columns do
      column do
        panel "最新抢红包记录" do
          table_for PartinTakeLog.order("id desc").limit(20) do
            column("用户") { |o| link_to o.user.format_nickname, cpanel_user_path(o.user) }
            column("商家Logo") { |o| link_to image_tag(o.partin.merchant.logo.url(:large), size: '48x48'), cpanel_merchant_path(o.partin.merchant) }
            column("商家名称") { |o| link_to o.partin.merchant.name, cpanel_merchant_path(o.partin.merchant) }
            column('广告封面图') { |o| image_tag o.partin.item_image_url, size: '64x64' }
            column("广告标题") { |o| link_to o.partin.item_title, [:cpanel, o.partin.info_item] }
            column("抢得金额") { |o| (o.resultable.try(:money) || 0) / 100.0 }
            column("时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
          end
        end
      end
    end
    # columns do
    #   column do
    #     panel "最新抢红包记录" do
    #       table_for RedbagEarnLog.order("id desc").limit(20) do
    #         column("用户") { |o| link_to o.user.format_nickname, cpanel_user_path(o.user) }
    #         column('红包封面图') { |o| image_tag o.redbag.try(:cover_image), size: '64x64' }
    #         column("红包主题") { |o| link_to o.redbag.title, [:cpanel, o.redbag] }
    #         column("抢得金额") { |o| o.money }
    #         column("时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
    #       end
    #     end
    #   end
    # end
    
    # 已经发过红包广告的商家
    # columns do
    #   column do
    #     panel "平台发过红包的用户" do
    #       @user_ids = Redbag.opened.not_share.select('distinct ownerable_id').map(&:ownerable_id)
    #       
    #       table_for User.includes(:redbags).where(id: @user_ids) do
    #         column('头像') { |o| image_tag o.real_avatar_url, size: '32x32' }
    #         column("昵称") { |o| link_to o.format_nickname, cpanel_user_path(o) }
    #         column('发红包个数') { |o| o.redbags.count }
    #         column('发红包总金额') { |o| o.redbags.sum(:total_money).to_f }
    #         column("最近一次发红包时间") { |o| o.redbags.not_share.order('id desc').first.created_at.strftime('%Y-%m-%d %H:%M') }
    #       end
    #     end
    #   end
    # end
    
    # 最新红包
    # columns do
    #   column do
    #     panel "最新发布的活动" do
    #       table_for Event.order("id desc").limit(20) do
    #         column("所有者") { |o| o.ownerable_type == 'User' ? link_to(o.ownerable.try(:format_nickname) || o.ownerable.email, cpanel_user_path(o.ownerable)) : o.ownerable.email }
    #         column('活动封面图') { |o| image_tag o.image.url(:small) }
    #         column("活动标题") { |o| o.title }
    #         column("红包金额") { |o| o.current_hb.try(:total_money) }
    #         column("活动状态") { |o| o.state_name }
    #         column("发布时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
    #       end
    #     end
    #   end
    # end
    
  # 用户分布图
    # columns do
    #   column do
    #     panel "所有用户位置分布" do
    #       div do
    #         @sessions = UserSession.where.not(begin_loc: nil)
    #         render 'cpanel/users/user_map', sessions: @sessions
    #       end
    #     end
    #   end
    # end
    
    # 活动红包排序
    # columns do
    #   column do
    #     panel "浏览最多的活动" do
    #       table_for Event.where('view_count > 0').order("view_count desc").limit(20) do
    #         column('活动封面图') { |o| image_tag o.image.url(:small) }
    #         column("活动标题") { |o| link_to o.title, cpanel_event_path(o) }
    #         column("浏览次数") { |o| o.view_count }
    #       end
    #     end
    #   end
    #   
    #   column do
    #     panel "抢红包最多的活动" do
    #       table_for Event.where('sent_hb_count > 0').order("sent_hb_count desc").limit(20) do
    #         column('活动封面图') { |o| image_tag o.image.url(:small) }
    #         column("活动标题") { |o| link_to o.title, cpanel_event_path(o) }
    #         column("被抢次数") { |o| o.sent_hb_count }
    #       end
    #     end
    #   end
    #   
    #   column do
    #     panel "转发最多的活动" do
    #       table_for Event.where('share_count > 0').order("share_count desc").limit(20) do
    #         column('活动封面图') { |o| image_tag o.image.url(:small) }
    #         column("活动标题") { |o| link_to o.title, cpanel_event_path(o) }
    #         column("转发次数") { |o| o.share_count }
    #       end
    #     end
    #   end
    #   
    # end
      
      # column do
      #   panel "当前在线用户" do
      #     table_for User.joins(:user_sessions).select('users.id, users.*').where('users.verified = ?', true).where('user_sessions.end_time > ?', Time.zone.now - 10.seconds).group('users.id') do
      #       column('头像') { |o| image_tag o.real_avatar_url, size: '32x32' }
      #       column("昵称") { |o| link_to o.format_nickname, cpanel_user_path(o) }
      #       column("在线时间") { |o| o.online_time }
      #     end
      #   end
      # end
    
  end # content
end
