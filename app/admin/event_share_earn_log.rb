ActiveAdmin.register EventShareEarnLog do

# menu priority: 6, label: '抢分享红包记录'

# menu parent: 'events', priority: 6
menu false

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
  column('ID', :id)
  column '分享用户', sortable: false do |log|
    link_to log.user.try(:format_nickname), [:cpanel, log.user]
  end
  column '被分享用户', sortable: false do |log|
    link_to log.for_user.try(:format_nickname), [:cpanel, log.for_user]
  end
  column '活动', sortable: false do |log|
    link_to log.event.try(:title), [:cpanel, log.event]
  end
  column '红包', sortable: false do |log|
    e = log.event
    if e.blank?
      '无效的活动'
    else      
      if e.share_hb.blank?
        '—'
      else
        raw("红包类型：#{e.share_hb._type == 0 ? '随机红包': '固定红包'}<br>红包金额：#{e.share_hb.total_money}<br>红包大小：#{e.share_hb._type == 1 ? e.share_hb.min_value : e.share_hb.min_value.to_s + '~' + e.share_hb.max_value.to_s}<br>剩余金额：#{e.share_hb.total_money - e.share_hb.sent_money}")
      end
    end
  end
  column :money
  column :created_at
  
  actions
end


end
