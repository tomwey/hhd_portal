ActiveAdmin.register PartinViewLog do
  menu parent: 'partin_stats', label: '广告浏览', priority: 1
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
index do
  selectable_column
  column('ID', :id)
  column '所属商家', sortable: false do |o|
    o.partin.merchant_id.blank? ? '' : link_to(o.partin.merchant.name, [:cpanel, o.partin.merchant])
  end
  column '广告', sortable: false do |o|
    o.partin.item_id.blank? ? '' : link_to(o.partin.info_item.title, [:cpanel, o.partin])
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
  column 'IP', :ip, sortable: false
  column '来源类型', sortable: false do |o|
    o.from_type == 0 ? 'APP客户端' : '网页'
  end
  column '位置坐标', sortable: false do |o|
    o.location
  end
  column 'at' do |o|
    o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
  end
  actions

end


end
