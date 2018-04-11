ActiveAdmin.register LocationCheckin do
  
  menu parent: 'hb_events', priority: 4, label: '签到规则'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :address, :location, :accuracy
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.semantic_errors
  
  f.inputs do
    f.input :address
    f.input :accuracy, as: :number
  end
  
  actions
end


end
