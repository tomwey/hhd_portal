ActiveAdmin.register EventEarnLog do

#menu priority: 5, label: '抢红包记录'

# menu parent: 'events', priority: 3
menu false

index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |log|
    link_to log.user.try(:format_nickname), [:cpanel, log.user]
  end
  column '活动', sortable: false do |log|
    link_to log.event.try(:title), [:cpanel, log.event]
  end
  column '红包', sortable: false do |log|
    e = log.event
    if e.blank?
      '无效的活动'
    else      
      if e.current_hb.blank?
        '—'
      else
        raw("红包类型：#{e.current_hb._type == 0 ? '随机红包': '固定红包'}<br>红包金额：#{e.current_hb.total_money}<br>红包大小：#{e.current_hb._type == 1 ? e.current_hb.min_value : e.current_hb.min_value.to_s + '~' + e.current_hb.max_value.to_s}<br>剩余金额：#{e.current_hb.total_money - e.current_hb.sent_money}")
      end
    end
  end
  column :money
  # column :ip, sortable: false
  # column :location, sortable: false
  column :created_at
  
  actions
end


end
