ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
# menu parent: 'user'
menu parent: 'users', priority: 1, label: '用户管理'

permit_params :mobile, :nickname, :avatar, :balance, :earn, :verified, :bio, :wx_id, :wx_avatar, :total_prize_count

filter :uid, as: :select, collection: User.includes(:wechat_profile).order('id desc').map { |u| ["#{u.uid}:#{u.wechat_profile.try(:nickname)}", u.uid] }
filter :wechat_profile_nickname, as: :string, label: '昵称'

scope :all, default: true
scope :followed
scope :unfollowed

index do
  selectable_column
  column('ID', :uid)
  column :avatar, sortable: false do |u|
    image_tag u.real_avatar_url, size: '32x32'
  end
  # column :mobile, sortable: false
  column :nickname, sortable: false do |u|
    u.format_nickname
  end
  column :balance
  column :earn
  # column :bio, sortable: false
  # column :verified, sortable: false
  column('关注时间') do |o| 
    o.wechat_profile.try(:subscribe_time).blank? ? '' : Time.at(o.wechat_profile.try(:subscribe_time).to_i).strftime('%Y年%m月%d日 %H:%M:%S')
  end
  column('取关时间') do |o|
    o.wechat_profile.try(:unsubscribe_time).blank? ? '' : o.wechat_profile.try(:unsubscribe_time).strftime('%Y年%m月%d日 %H:%M:%S')
  end
  column :created_at
  actions defaults: false do |u|
    item "查看", cpanel_user_path(u)
    if current_admin.admin?
      item "编辑", edit_cpanel_user_path(u)
      if u.verified
        item "禁用", block_cpanel_user_path(u), method: :put, data: { confirm: '你确定吗？' }, class: 'danger'
      else
        item "启用", unblock_cpanel_user_path(u), method: :put, data: { confirm: '你确定吗？' }
      end
    
    end
    # item "删除", cpanel_user_path(u), method: :delete, data: { confirm: '你确定吗？' }
  end
  
end

# 禁用账户
batch_action :block do |ids|
  batch_action_collection.find(ids).each do |o|
    o.block!
  end
  redirect_to collection_path, alert: "已禁用"
end
member_action :block, method: :put do
  resource.block!
  redirect_to collection_path, notice: '禁用成功'
end

# 启用账户
batch_action :unblock do |ids|
  batch_action_collection.find(ids).each do |o|
    o.unblock!
  end
  redirect_to collection_path, alert: "已启用"
end
member_action :unblock, method: :put do
  resource.unblock!
  redirect_to collection_path, notice: '启用成功'
end

# 开启余额抵扣
batch_action :enable_pay do |ids|
  batch_action_collection.find(ids).each do |o|
    o.enable_pay!
  end
  redirect_to collection_path, alert: "已开启"
end

member_action :enable_pay, method: :put do
  resource.enable_pay!
  redirect_to collection_path, notice: '开启成功'
end

# 关闭余额抵扣
batch_action :disable_pay do |ids|
  batch_action_collection.find(ids).each do |o|
    o.disable_pay!
  end
  redirect_to collection_path, alert: "已关闭"
end
member_action :disable_pay, method: :put do
  resource.disable_pay!
  redirect_to collection_path, notice: '关闭成功'
end

form html: { multipart: true } do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    # f.input :mobile
    f.input :nickname
    f.input :avatar, as: :file, hint: '图片格式为：jpg,jpeg,png,gif'
    f.input :balance
    f.input :earn
    f.input :total_prize_count
    # f.input :bio
    # f.input :verified, as: :boolean
  end
  # f.inputs '微信认证信息' do
  #   f.input :wx_id
  #   f.input :wx_avatar
  # end
  actions
  
end

show do
  attributes_table do
    row :avatar do |u|
      image_tag u.real_avatar_url, size: '60x60'
    end
    row :uid
    row :mobile
    row :nickname do |u|
      u.format_nickname
    end
    row :balance
    row :earn
    row :private_token
    row :created_at
  end
  
  panel "微信资料" do
    if user.wechat_profile
      table_for user.wechat_profile do
        column :openid
        column :nickname
        column('性别') { |o| o.sex == 0 ? '男' : '女' }
        column :language
        column :city
        column :province
        column('关注时间') { |o| o.subscribe_time.blank? ? '' : Time.at(o.subscribe_time.to_i).strftime('%Y年%m月%d日 %H:%M:%S') }
        column('取关时间') { |o| o.unsubscribe_time.blank? ? '' : o.unsubscribe_time.strftime('%Y年%m月%d日 %H:%M:%S') }
        # column :unionid
        # column :access_token
        # column :refresh_token
        # column :created_at
      end
    else
      '无数据显示'
    end
  end
  
  panel "汇总数据" do
    table class: 'stat-table' do
      tr do
        th '总会话'
        th '红包浏览次数'
        th '抢红包次数'
        th '抢红包金额'
        th '分享红包次数'
        th '分享红包收益'
        th '提现次数'
        th '提现金额'
        th '充值次数'
        th '充值金额'
      end
      tr do
        # 总会话
        @session_count ||= UserSession.where(user_id: user.id).count
        
        # 红包浏览次数
        @user_hb_view_count ||= RedbagViewLog.where(user_id: user.id).count
        
        # 抢红包次数
        @user_hb_earn_count ||= RedbagEarnLog.where(user_id: user.id).count
        
        # 抢红包金额
        @user_hb_earn_money ||= RedbagEarnLog.where(user_id: user.id).sum(:money).to_f
        
        # 分享红包次数
        @user_share_hb_count ||= RedbagShareLog.where(user_id: user.id).count
        
        # 分享红包金额
        @user_share_hb_earn_money ||= RedbagShareEarnLog.where(user_id: user.id).sum(:money).to_f
        
        # 提现次数
        @user_withdraw_count ||= Withdraw.where(user_id: user.id).count
        
        # 提现金额
        @user_withdraw_money ||= Withdraw.where(user_id: user.id).sum(:money).to_f
        
        # 充值次数
        @user_charge_count ||= Charge.where(user_id: user.id).where.not(payed_at: nil).count
        
        # 充值金额
        @user_charge_money ||= Charge.where(user_id: user.id).where.not(payed_at: nil).sum(:money).to_f
        
        td @session_count
        td @user_hb_view_count
        td @user_hb_earn_count
        td @user_hb_earn_money
        td @user_share_hb_count
        td @user_share_hb_earn_money
        td @user_withdraw_count
        td @user_withdraw_money
        td @user_charge_count
        td @user_charge_money
      end # end tr
      
    end # end total data
    
    table class: 'stat-table' do
      tr do
        th '今日会话'
        th '今日红包浏览次数'
        th '今日抢红包次数'
        th '今日抢红包金额'
        th '今日分享红包次数'
        th '今日分享红包收益'
      end
      tr do
        # 总会话
        @today_session_count ||= UserSession.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        
        # 红包浏览次数
        @today_user_hb_view_count ||= RedbagViewLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        
        # 抢红包次数
        @today_user_hb_earn_count ||= RedbagEarnLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        
        # 抢红包金额
        @today_user_hb_earn_money ||= RedbagEarnLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:money).to_f
        
        # 分享红包次数
        @today_user_share_hb_count ||= RedbagShareLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        
        # 分享红包金额
        @today_user_share_hb_earn_money ||= RedbagShareEarnLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:money).to_f
        
        td @today_session_count
        td @today_user_hb_view_count
        td @today_user_hb_earn_count
        td @today_user_hb_earn_money
        td @today_user_share_hb_count
        td @today_user_share_hb_earn_money
      end # end tr
      
    end # end today data
  end # end panel 
    
  panel "提现列表" do
    table_for Withdraw.where(user_id: user.id) do
      column('流水号') { |o| o.oid }
      column('账号') { |o| o.account_no }
      column('姓名') { |o| o.account_name }
      column('金额') { |o| o.money }
      column('手续费') { |o| o.fee }
      column('提现支付时间') { |o| o.payed_at.blank? ? '' : o.payed_at.strftime('%Y年%m月%d日 %H:%M:%S') }
      column('提现申请时间') { |o| o.created_at.strftime('%Y年%m月%d日 %H:%M:%S') }
    end
  end
  
  panel "充值列表" do
    table_for Charge.where(user_id: user.id).where.not(payed_at: nil) do
      column('流水号') { |o| o.uniq_id }
      column('金额') { |o| o.money }
      column('到账时间') { |o| o.payed_at.blank? ? '' : o.payed_at.strftime('%Y年%m月%d日 %H:%M:%S') }
      column('充值时间') { |o| o.created_at.strftime('%Y年%m月%d日 %H:%M:%S') }
    end
  end
  
  panel "最新抢红包收益数据" do
    table_for RedbagEarnLog.where(user_id: user.id).order("id desc").limit(30) do
      column('流水号') { |o| link_to o.uniq_id, [:cpanel, o] }
      column('红包封面图') { |o| image_tag o.redbag.try(:cover_image), size: '64x64' }
      column("红包主题") { |o| link_to o.redbag.title, [:cpanel, o.redbag] }
      column("红包总金额") { |o| o.redbag.total_money }
      column("红包类型") { |o| o.redbag._type == 0 ? '随机红包' : '固定红包' }
      column("抢得金额") { |o| o.money }
      column("时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
    end
  end
  
  panel "分享过的红包" do
    @redbag_ids = user.redbag_share_logs.select('distinct redbag_id').map(&:redbag_id)
    table_for Redbag.where(id: @redbag_ids) do
      column("红包ID") { |o| link_to o.uniq_id, [:cpanel, o] }
      column('红包封面图') { |o| image_tag o.try(:cover_image), size: '64x64' }
      column("红包主题") { |o| link_to o.title, [:cpanel, o] }
      column("红包总金额") { |o| o.total_money }
      column("红包类型") { |o| o._type == 0 ? '随机红包' : '固定红包' }
      column("红包收益") { |o| "#{o._type == 0 ? (o.min_value.to_s + '~' + o.max_value.to_s) : o.min_value}" }
      column("红包用途") { |o| I18n.t("common.redbag.use_type_#{o.use_type}") }
      column('分享次数') { |o| RedbagShareLog.where(user_id: user.id, redbag_id: o.id).count }
      # column("最新分享时间") { |o| o.share_time.strftime('%Y-%m-%d %H:%M:%S') }
      column("红包状态") { |o| o.opened ? '上架' : '下架' }
    end
  end
  
  panel "发布的红包" do
    table_for Redbag.where(ownerable: user).order("id desc") do
      column("红包ID") { |o| link_to o.uniq_id, [:cpanel, o] }
      column('红包封面图') { |o| image_tag o.try(:cover_image), size: '64x64' }
      column("红包主题") { |o| link_to o.title, [:cpanel, o] }
      column("红包总金额") { |o| o.total_money }
      column("红包类型") { |o| o._type == 0 ? '随机红包' : '固定红包' }
      column("红包收益") { |o| "#{o._type == 0 ? (o.min_value.to_s + '~' + o.max_value.to_s) : o.min_value}" }
      column("红包用途") { |o| I18n.t("common.redbag.use_type_#{o.use_type}") }
      column("发布时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
      column("红包状态") { |o| o.opened ? '上架' : '下架' }
    end
  end
  
  panel "会话地图" do
    @sessions = UserSession.where(user_id: user.id).where.not(begin_loc: nil)
    render 'user_map', sessions: @sessions
  end
  
end


end
