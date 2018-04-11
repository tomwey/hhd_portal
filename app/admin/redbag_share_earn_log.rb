ActiveAdmin.register RedbagShareEarnLog do

  menu parent: 'hb', priority: 21
  
  index do
    selectable_column
    column('ID', :id)
    column '用户', sortable: false do |log|
      link_to log.user.try(:format_nickname), [:cpanel, log.user]
    end
    column '来自用户', sortable: false do |log|
      if log.for_user
        link_to log.for_user.try(:format_nickname), [:cpanel, log.for_user]
      else
        ''
      end
    end
    column '红包信息', sortable: false do |log|
      hb = log.redbag
      if hb
        raw("红包类型：#{hb._type == 0 ? '随机红包': '固定红包'}<br>红包金额：#{hb.total_money}<br>红包大小：#{hb._type == 1 ? hb.min_value : hb.min_value.to_s + '~' + hb.max_value.to_s}<br>剩余金额：#{hb.total_money - hb.sent_money}")
      else
        ''
      end
    end
    column :money
    # column :ip, sortable: false
    # column :location, sortable: false
    column :created_at
  
    actions
  end

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


end
