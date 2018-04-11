ActiveAdmin.register Redbag do

# menu parent: 'hb', priority: 1

# menu priority: 6, label: '红包'
menu parent: 'hb_events', priority: 6, label: '红包'

permit_params :title, :_type, :f_total_money, :f_min_value, :f_max_value, :f_total, :f_value, :sort, 
  :uid, :hb_type, :rule_type,:address, :range, :started_at, 
  :share_title, :share_hb_id, :use_type, :win_score, :card_id, :share_poster_id,
  wechat_redbag_config_attributes: [:id, :send_name, :wishing, :act_name, :remark, :scene_id, :_destroy],
  redbag_prizes_attributes: [:id, :name, :quantity, :score, :_destroy]
  
scope 'Events', :event, default: true
# scope 'Poster Events', :poster
scope 'Shares', :share
# scope 'Cashes', :cash
scope 'Checkins', :checkin
scope :all

index do
  selectable_column
  column('ID', :uniq_id)
  column '所有者', sortable: false do |hb|
    # hb.ownerable_id.blank? ? '' : link_to(hb.ownerable_id, [:cpanel, hb.ownerable])
    link_to hb.ownerable.try(:format_nickname) || hb.ownerable.try(:email), [:cpanel, hb.ownerable]
  end
  column :title, sortable: false
  column '红包用途', sortable: false do |hb|
    I18n.t("common.redbag.use_type_#{hb.use_type}")
  end
  column :total_money
  column :sent_money
  column '抢红包金额' do |hb|
    "#{hb._type == 0 ? (hb.min_value.to_s + '~' + hb.max_value.to_s) : hb.min_value}"
  end
  
  column '分享红包', sortable: false do |hb|
    # hb.share_poster_id.blank? ? '' :
    # link_to(image_tag(hb.share_poster.image.url(:small)), [:cpanel, hb.share_poster])
    # if hb.share_hb
    #   link_to "#{hb.share_hb.uniq_id}: #{hb.share_hb.sent_money} / #{hb.share_hb.total_money}
    #     (#{hb.share_hb.min_value}-#{hb.share_hb.max_value})", [:cpanel, hb.share_hb]
    # else
    #   ''
    # end
  end
  column('at', :created_at)
  
  actions defaults: false do |o|
    item "查看", [:cpanel, o]
    
    if current_admin.admin?
      if o.use_type != Redbag::USE_TYPE_SHARE
        if not o.opened
        #   item "下架", close_cpanel_redbag_path(o), method: :put
        # else
          item "上架", open_cpanel_redbag_path(o), method: :put, data: { confirm: '您确定吗？' }
        else
          item "下架", close_cpanel_redbag_path(o), method: :put, data: { confirm: '您确定吗？' }
        end
      end
      # if o.opened == false || o.left_money <= 0
      item "编辑", edit_cpanel_redbag_path(o)
    
      if o.use_type == Redbag::USE_TYPE_EVENT && o.left_money <= 0.0
        item "再次发起", edit2_cpanel_redbag_path(o)
      end
    end
    # end
    # item "删除", cpanel_redbag_path(o), method: :delete, data: { confirm: '你确定吗？' }
  end
  
end

show do 
  panel "红包数据汇总" do
    table class: 'stat-table' do
      tr do
        th '总金额(元)'
        th '已抢金额(元)'
        th '浏览数'
        if current_admin.super_admin?
          th '浏览用户'
          th '匿名浏览数'
        end
        th '参与数'
        th '分享数'
      end
      tr do
        td redbag.total_money
        td redbag.sent_money
        td redbag.view_count
        if current_admin.super_admin?
          td RedbagViewLog.select('distinct user_id').where(redbag_id: redbag.id).where.not(user_id: nil).count
          td RedbagViewLog.where(redbag_id: redbag.id, user_id: nil).count
        end
        td redbag.sent_count
        td redbag.share_count
      end
    end # end table
  end
  
  panel "最新抢红包记录" do
    table_for redbag.redbag_earn_logs.order("id desc").limit(20) do
      column("用户") { |o| o.user.blank? ? '' : link_to(o.user.try(:format_nickname), cpanel_user_path(o.user))  }
      column("抢得金额") { |o| o.money }
      column('位置') { |o| o.location }
      column('IP') { |o| o.ip }
      column("时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
    end
  end
  
  panel "最新浏览记录" do
    table_for redbag.redbag_view_logs.order("id desc").limit(20) do
      column("用户") { |o| o.user.blank? ? '' : link_to(o.user.try(:format_nickname), cpanel_user_path(o.user)) }
      column('位置') { |o| o.location }
      column('IP') { |o| o.ip }
      column("时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
    end
  end
  
  panel '红包用户分布' do
    view_locations = redbag.redbag_view_logs.where.not(location: nil).pluck(:location)
    earn_locations = redbag.redbag_earn_logs.where.not(location: nil).pluck(:location)
    
    render 'redbag_user_map', view_locations: view_locations, earn_locations: earn_locations
  end
  
end

# 上架
batch_action :open do |ids|
  batch_action_collection.find(ids).each do |e|
    e.open!
  end
  redirect_to collection_path, alert: "已上架"
end
member_action :open, method: :put do
  resource.open!
  redirect_to collection_path, notice: '已上架'
end

member_action :edit2, method: :get, label: '再次发布' do

end

member_action :republish, method: :put do
  
end

controller do 
  def edit2
    @redbag = Redbag.find(params[:id])
  end
  
  def republish
    @redbag = Redbag.find(params[:id])
    # ownerable = @redbag.ownerable
    if @redbag.ownerable_type == 'User'
      ownerable = @redbag.ownerable
      
      hb_params = params[:redbag]
      
      type = hb_params[:_type].to_i
      
      # 记录版本
      if RedbagVersion.where(redbag_id: @redbag.id).count == 0
        value = { _type: @redbag._type, 
                  total_money: @redbag.total_money,
                  min_value: @redbag.min_value,
                  max_value: @redbag.max_value
                 }
        RedbagVersion.create!(redbag_id: @redbag.id, value: value)
      end
      
      if type == 0
        # 随机
        if hb_params[:f_total_money].blank? or hb_params[:f_min_value].blank? or hb_params[:f_max_value].blank?
          msg = '有必填字段未填'
        else
          msg = nil
          total = hb_params[:f_total_money].to_f
          min   = hb_params[:f_min_value].to_f
          max   = hb_params[:f_max_value].to_f
          
          if min > max 
            msg = '最小值不能大于最大值'
          end
          
          if max > total
            msg = '最大值不能大于红包总金额'
          end
          
        end
      else
        # 固定
        if hb_params[:f_total].blank? or hb_params[:f_value].blank?
          msg = '红包个数或单个红包大小为必填'
        else
          msg = nil
          total = hb_params[:f_total].to_i * hb_params[:f_value].to_f
          min   = hb_params[:f_value].to_f
          max   = hb_params[:f_value].to_f
        end
        
      end
      
      unless msg.blank?
        redirect_to edit2_cpanel_redbag_path(@redbag), alert: msg
        return
      end
      
      total_money = total
      
      has_shb = false
      
      if @redbag.share_hb
        share_hb_type = hb_params[:redbag][:_type].to_i
        if ( (hb_params[:redbag][:f_total_money] && hb_params[:redbag][:f_min_value] && 
            hb_params[:redbag][:f_max_value]) or
          (hb_params[:redbag][:f_total] && hb_params[:redbag][:f_value]) )
          if share_hb_type == 0
            # 随机
            s_total = hb_params[:redbag][:f_total_money].to_f
            s_min   = hb_params[:redbag][:f_min_value].to_f
            s_max   = hb_params[:redbag][:f_max_value].to_f
          else
            # 固定
            s_total = hb_params[:redbag][:f_total].to_i * hb_params[:redbag][:f_value].to_f
            s_min   = hb_params[:redbag][:f_value].to_f
            s_max   = hb_params[:redbag][:f_value].to_f
          end
          
          total_money += s_total
        
          if (s_min > 0.0 && s_max > 0.0)
            has_shb = true
          end
          
        end
      end
      
      if ownerable.balance < total_money
        redirect_to edit2_cpanel_redbag_path(@redbag), alert: '余额不足'
        return
      end
      
      @redbag.total_money += total
      @redbag.min_value = min
      @redbag.max_value = max
      
      @redbag._type = type
      
      @redbag.save!
      
      # 扣除用户的钱
      ownerable.balance -= total_money
      ownerable.save!
      
      # 记录当前版本
      val = { _type: type, 
              total_money: total,
              min_value: min,
              max_value: max
              }
      lv1 = RedbagVersion.create!(redbag_id: @redbag.id, value: val)
      
      # 添加交易明细
      TradeLog.create!(tradeable: lv1, user_id: ownerable.id, money: total, title: '发布广告红包')
      
      if has_shb
        hb = @redbag.share_hb
        
        if RedbagVersion.where(redbag_id: @redbag.share_hb.try(:id)).count == 0
          value = { _type: share_hb_type, 
                    total_money: s_total,
                    min_value: s_min,
                    max_value: s_max
                   }
          RedbagVersion.create!(redbag_id: hb.id, value: value)
        end
        
        hb.total_money += s_total
        hb.min_value = s_min
        hb.max_value = s_max
        
        hb._type = share_hb_type
        
        hb.save!
        
        # 记录当前版本
        val = { _type: share_hb_type, 
                total_money: s_total,
                min_value: s_min,
                max_value: s_max
                }
        lv2 = RedbagVersion.create!(redbag_id: hb.id, value: val)
        
        # 添加交易明细
        TradeLog.create!(tradeable: lv2, user_id: ownerable.id, money: s_total, title: '发布分享红包')
        
      end
      
      # 发送推送消息
      payload = {
        first: {
          value: "惠互动已经将您的红包再次发布\n",
          color: "#FF3030",
        },
        keyword1: {
          value: "#{@redbag.title}",
          color: "#173177",
        },
        keyword2: {
          value: "再次发布",
          color: "#173177",
        },
        remark: {
          value: "现在可以开始抢红包了~",
          color: "#173177",
        }
      }.to_json
    
      Message.create!(message_template_id: 4, 
        content: payload,link: SiteConfig.wx_app_url, to_users: [ownerable.id])
      
      redirect_to cpanel_redbags_url, notice: '再次发布成功'
    else
      redirect_to cpanel_redbags_url, alert: '您操作的不是一个User'
    end
    
  end
end

# 下架
batch_action :close do |ids|
  batch_action_collection.find(ids).each do |e|
    e.close!
  end
  redirect_to collection_path, alert: "已下架"
end
member_action :close, method: :put do
  resource.close!
  redirect_to collection_path, notice: '已下架'
end

before_create do |o|
  if o._type == 0
    # 随机红包
    o.total_money = o.f_total_money
    o.min_value   = o.f_min_value
    o.max_value   = o.f_max_value
  else
    # 固定红包
    o.total_money = o.f_total.to_i * o.f_value.to_f
    o.min_value = o.max_value = o.f_value.to_f
  end
end

# before_update do |o|
#   puts o
# end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    if f.object.new_record? || !f.object.opened
      f.input :uid, as: :select, label: '所有者ID', 
        collection: User.includes(:wechat_profile).where(verified: true)
                  .order('id desc').map { |u| ["[#{u.uid}] #{u.format_nickname}", u.uid] }, 
        prompt: '-- 选择所有者 --', required: true, input_html: { style: 'width: 50%;' }
    end
    f.input :title
    if f.object.new_record?
      f.input :use_type, as: :select, collection: Redbag.use_types, 
        label: '红包用途', prompt: '-- 选择红包用途 --', required: true, input_html: { style: 'width: 280px;' }
      f.input :_type, as: :select, collection: [['随机红包', 0], ['固定红包', 1]], 
        prompt: '-- 选择红包类型 --', required: true, input_html: { style: 'width: 280px;' }
      f.input :f_total_money, as: :number, label: '总金额', required: true
      f.input :f_min_value, as: :number, label: '最小金额', required: true
      f.input :f_max_value, as: :number, label: '最大金额', required: true
      f.input :f_total, as: :number, required: true, label: '红包个数'
      f.input :f_value, as: :number, required: true, label: '单个红包金额'
    end
    # f.input :win_score, label: '概率值'
    f.input :sort
    # f.input :opened
    
  end
  
  f.inputs "微信现金红包配置", 
    data: { is_cash: "#{(f.object.new_record? || f.object._type != Redbag::USE_TYPE_CASH) ? '0' : '1'}" }, 
    id: 'wechat-redbag-configs', 
    for: [:wechat_redbag_config, (f.object.wechat_redbag_config || WechatRedbagConfig.new)] do |s|
    s.input :send_name
    s.input :wishing
    s.input :act_name
    s.input :remark
    s.input :scene_id, as: :select, collection: Redbag.wx_send_scenes, 
      prompt: '-- 选择红包发送场景 --',input_html: { style: 'width: 240px;' }
  end
  
  # f.inputs "多个奖项信息", id: 'redbag-prizes-inputs' do
  #   f.has_many :redbag_prizes, allow_destroy: true, heading: '红包奖项信息' do |item_form|
  #       item_form.input :name, as: :select,
  #         collection: Redbag.prizes_data_for(current_admin), prompt: '-- 选择奖品 --',
  #         input_html: { style: 'width: 240px;' }
  #       item_form.input :score, hint: '中奖概率值，是一个整数，如果设置为0，表示不会抽中该奖项'
  #       item_form.input :quantity, hint: '该奖项可以被抽到的数量，如果不设置，那么可以抽无数次'
  #   end
  # end
  
  f.inputs '红包关联信息', id: 'redbag-rule-inputs' do
    f.input :hb_type, as: :select, label: '红包广告', collection: Redbag.hb_types, 
      prompt: '-- 选择红包广告 --', input_html: { style: 'width: 240px;' }
    f.input :rule_type, as: :select, label: '红包规则', collection: Redbag.rule_types, 
      prompt: '-- 选择红包规则 --', input_html: { style: 'width: 240px;' }
  end
  f.inputs '红包分享信息', id: 'redbag-share-inputs' do
    f.input :share_title, label: '分享标题', hint: '红包分享标题可以自定义，如果没有设置该值，默认用红包的主题作为分享标题'
    f.input :share_hb_id, as: :select, label: '设置分享红包', collection: Redbag.share_hbs,
      prompt: '-- 选择一个分享红包 --', input_html: { style: 'width: 240px;' }
  end
  f.inputs '选填信息', id: 'redbag-options-inputs' do
    # f.input :share_poster_id, as: :select, label: '分享海报', collection: SharePoster.all.map { |o| [o.title, o.id] },
      # prompt: '-- 选择海报 --', input_html: { style: 'width: 240px;' }
    f.input :card_id, as: :select, label: '优惠卡', collection: Redbag.cards,
      prompt: '-- 选择优惠卡 --', input_html: { style: 'width: 240px;' }
    # f.input :location_str, label: '红包位置坐标', placeholder: '输入经纬度坐标，例如：104.039393,90.9484921'
    f.input :address, label: '红包位置', hint: '输入详细的位置，位置前必须要加城市', 
      placeholder: '例如：成都市绿地世纪城或成都市青羊区西大街1号'
    f.input :range, label: '限制范围', hint: '单位为米'
    f.input :started_at, label: '开抢时间', as: :string, placeholder: '2017-09-09 12:09'
  end
  actions
end


end
