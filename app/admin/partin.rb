ActiveAdmin.register Partin do
  menu parent: 'merchants', priority: 8, label: '广告'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :item_id, :rule_type, :win_type, :rule_answer_tip, :sort, :need_notify,
#   :location_str, :range, :online_at, :opened,:need_share,
#   partin_share_config_attributes: [:id, :icon, :title, :win_type, :_destroy]
  
  config.filters = false

index do
  selectable_column
  column('ID', :uniq_id)
  column '所属商家', sortable: false do |o|
    link_to o.merchant.name, [:cpanel, o.merchant]
  end
  column '广告标题', sortable: false do |o|
    o.item_id.blank? ? '' : link_to(o.info_item.title, [:cpanel, o.info_item])
  end
  column '参与奖励', sortable: false do |o|
    o.winnable_id.blank? ? '' : link_to(o.winnable.format_type_name, [:cpanel, o.winnable])
  end
  column '参与规则', sortable: false do |o|
    o.ruleable_id.blank? ? '' : link_to(o.ruleable.format_type_name, [:cpanel, o.ruleable])
  end
  column '状态', sortable: false do |o|
    o.can_take ? '有剩余' : '已抢完'
  end
  # column :rule_answer_tip, sortable: false
  # column :need_notify, sortable: false do |o|
  #   o.need_notify ? '需要' : '不需要'
  # end

  column('at', :created_at)

  actions defaults: false do |o|
    item "查看", [:cpanel, o]
      
    if not o.opened
    #   item "下架", close_cpanel_redbag_path(o), method: :put
    # else
      item "上架", open_cpanel_partin_path(o), method: :put, data: { confirm: '您确定吗？' }
    else
      item "下架", close_cpanel_partin_path(o), method: :put, data: { confirm: '您确定吗？' }
    end
    item "编辑", edit_cpanel_partin_path(o)
    
    # end
    # item "删除", cpanel_redbag_path(o), method: :delete, data: { confirm: '你确定吗？' }
  end

end

show do 
  panel "广告数据汇总" do
    table class: 'stat-table' do
      tr do
        th '总金额(元)'
        th '已抢金额(元)'
        th '浏览数'
        th '参与数'
        th '分享数'
      end
      tr do
        td partin.winnable.try(:total_money) / 100.0
        td partin.winnable.try(:sent_money) / 100.0
        td partin.view_count
        td partin.take_count
        td partin.share_count
      end
    end # end table
  end
  
  panel "最新参与记录" do
    table_for partin.partin_take_logs.order("id desc").limit(20) do
      column("用户") { |o| o.user.blank? ? '' : link_to(o.user.try(:format_nickname), cpanel_user_path(o.user))  }
      column("抢得金额") { |o| (o.resultable.try(:money) || 0) / 100.0 }
      column('位置') { |o| o.location }
      column('IP') { |o| o.ip }
      column("时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
    end
  end
  
  panel "最新浏览记录" do
    table_for partin.partin_view_logs.order("id desc").limit(20) do
      column("用户") { |o| o.user.blank? ? '' : link_to(o.user.try(:format_nickname), cpanel_user_path(o.user)) }
      column('位置') { |o| o.location }
      column('IP') { |o| o.ip }
      column("时间") { |o| o.created_at.strftime('%Y-%m-%d %H:%M:%S') }
    end
  end
  
  panel '用户分布' do
    view_locations = partin.partin_view_logs.where.not(location: nil).pluck(:location)
    earn_locations = partin.partin_take_logs.where.not(location: nil).pluck(:location)
    
    render 'partin_user_map', view_locations: view_locations, earn_locations: earn_locations
  end
  
end

# 上架
# batch_action :open do |ids|
#   batch_action_collection.find(ids).each do |e|
#     e.open!
#   end
#   redirect_to collection_path, alert: "已上架"
# end
member_action :open, method: :put do
  flag = resource.open! # ? '已上架' : '余额不足,上架失败'
  if flag
    redirect_to collection_path, notice: '上架成功'
  else
    redirect_to collection_path, alert: '上架失败，余额不足'
  end
end

# 下架
# batch_action :close do |ids|
#   batch_action_collection.find(ids).each do |e|
#     e.close!
#   end
#   redirect_to collection_path, alert: "已下架"
# end
member_action :close, method: :put do
  resource.close!
  redirect_to collection_path, notice: '已下架'
end

# before_create do |o|
#   o.merchant = current_admin_user.merchant
# end
#
# form do |f|
#   f.semantic_errors
#   f.inputs '基本信息' do
#     f.input :item_id, as: :select, label: '广告内容', collection: Partin.items_for(current_admin_user.merchant_id),prompt: '-- 选择参与内容 --'
#     f.input :rule_type, as: :select, label: '参与规则', collection: Partin.rule_types_for(current_admin_user.merchant_id), prompt: '-- 选择参与规则 --'
#     if f.object.new_record? or !f.object.opened
#     f.input :win_type,  as: :select, label: '参与奖励', collection: Partin.win_types_for(current_admin_user.merchant_id, f.object), prompt: '-- 选择参与奖励 --'
#     end
#     f.input :rule_answer_tip, placeholder: '题目的答案在广告内容中找，注意只有一次回答机会。'
#     f.input :need_notify
#
#     if f.object.new_record? or !f.object.opened
#     f.input :need_share, as: :boolean, label: '是否支持微信分享', input_html: { onchange: 'Partin.toggleShareConfig(this)' }
#     end
#     # f.input :opened
#     f.input :sort
#   end
#
#   f.inputs "微信分享配置",
#     data: { need_share: "#{(f.object.new_record? || f.object.need_share == true) ? '1' : '0'}" },
#     id: 'partin-share-configs',
#     for: [:partin_share_config, (f.object.partin_share_config || PartinShareConfig.new)] do |s|
#     s.input :icon, label: '分享图标', hint: '格式为png,jpg,jped,gif,尺寸为正方形'
#     s.input :icon_cache, as: :hidden
#     s.input :title, label: '分享标题'
#     if f.object.new_record? or !f.object.opened # 如果还未创建或者没有上架，可以进行修改
#       s.input :win_type,  as: :select, label: '分享者奖励', collection:     PartinShareConfig.win_types_for(current_admin_user.merchant_id, s.object),
#       prompt: '-- 选择参与奖励 --'
#     end
#   end
#
#   f.inputs '范围信息' do
#     f.input :location_str, label: '参与地址', placeholder: '输入详细的参与地址，例如：成都市西大街1号'
#     f.input :range, placeholder: '单位为米'
#     f.input :online_at, as: :string, placeholder: '2017-09-01 12:30'
#   end
#
#   actions
# end

end
