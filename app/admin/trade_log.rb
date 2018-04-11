ActiveAdmin.register TradeLog do

menu parent: 'money', priority: 3, label: '交易记录'

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
  column '用户', sortable: false do |log|
    link_to log.user.try(:uid), [:cpanel, log.user]
  end
  # column '交易对象', sortable: false do |log|
  #   
  # end
  column :title, sortable: false
  column :money
  # column :ip, sortable: false
  # column :location, sortable: false
  column :created_at
  
  actions
end


end
