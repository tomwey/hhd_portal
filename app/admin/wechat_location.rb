ActiveAdmin.register WechatLocation do

menu parent: 'users', priority: 5, label: '用户位置'

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
  column '用户', sortable: false do |loc|
    link_to loc.user.try(:uid), [:cpanel, loc.user]
  end
  column :address, sortable: false
  column :formated_address, sortable: false
  column '坐标', sortable: false do |loc|
    "#{loc.lng},#{loc.lat}"
  end
  column :precision
  column :created_at
  
  actions
end


end
