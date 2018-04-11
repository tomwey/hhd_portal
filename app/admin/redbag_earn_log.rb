ActiveAdmin.register RedbagEarnLog do

  menu parent: 'hb', priority: 20
  
  index do
    selectable_column
    column('ID', :id)
    column '用户', sortable: false do |log|
      link_to log.user.try(:format_nickname), [:cpanel, log.user]
    end
    column '红包主题', sortable: false do |log|
      link_to log.redbag.try(:title), [:cpanel, log.redbag]
    end
    column '红包信息', sortable: false do |log|
      hb = log.redbag
      raw("红包类型：#{hb._type == 0 ? '随机红包': '固定红包'}<br>红包金额：#{hb.total_money}<br>红包大小：#{hb._type == 1 ? hb.min_value : hb.min_value.to_s + '~' + hb.max_value.to_s}<br>剩余金额：#{hb.total_money - hb.sent_money}")
    end
    column :money
    # column :ip, sortable: false
    # column :location, sortable: false
    column :created_at
  
    actions
  end


end
