ActiveAdmin.register UserSession do
  
  menu parent: 'users', priority: 2, label: '用户会话'

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
  column '用户', sortable: false do |us|
    link_to us.user.format_nickname, [:cpanel, us.user]
  end
  column :begin_time
  column :end_time
  # column '位置', sortable: false do |us|
  #   raw("1、#{us.begin_loc}<br>2、#{us.end_loc}")
  # end
  column '网络', sortable: false do |us|
    raw("1、#{us.begin_network}<br>2、#{us.end_network}")
  end
  column '客户端版本号', :version
  # column 'IP', sortable: false do |us|
  #   raw("1、#{us.begin_ip}<br>2、#{us.end_ip}")
  # end
  column('at', :created_at)
  
  actions
end


end
