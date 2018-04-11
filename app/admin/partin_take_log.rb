ActiveAdmin.register PartinTakeLog do
  menu parent: 'partin_stats', label: '广告参与', priority: 3
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
index do
  selectable_column
  column('ID', :uniq_id)
  column '所属商家', sortable: false do |o|
    o.partin.merchant_id.blank? ? '' : link_to(o.partin.merchant.name, [:cpanel, o.partin.merchant])
  end
  column '用户', sortable: false do |o|
    # o.user_id.blank? ? '' : link_to(o.user.format_nickname, [:admin, o.user])
    if o.user_id.blank?
      ''
    else
      # image_tag(o.user.avatar_url(:small))
      o.user.format_nickname
    end
  end
  column '来自用户', sortable: false do |o|
    # o.user_id.blank? ? '' : link_to(o.user.format_nickname, [:admin, o.user])
    if o.from_user_id.blank?
      ''
    else
      # image_tag(o.user.avatar_url(:small))
      o.from_user.try(:format_nickname)
    end
  end
  column '广告', sortable: false do |o|
    o.partin.item_id.blank? ? '' : link_to(o.partin.info_item.title, [:cpanel, o.partin])
  end
  column '参与结果', sortable: false do |o|
    o.resultable.blank? ? '无' : link_to(o.resultable.format_name, [:cpanel, ( o.resultable.try(:redpack) || o.resultable.try(:card))])
  end
  column 'IP', :ip, sortable: false
  column '位置坐标', sortable: false do |o|
    o.location
  end
  column 'at' do |o|
    o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
  end
  actions

end

end
