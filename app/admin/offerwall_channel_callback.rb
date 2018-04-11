ActiveAdmin.register OfferwallChannelCallback do

  menu parent: 'offerwall', priority: 2

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
  column :order, sortable: false
  column :ad_name, sortable: false
  column '所属用户', sortable: false do |o|
    o.user.blank? ? '--' : link_to(o.user.try(:format_nickname), [:cpanel, o.user])
  end
  column '所属渠道', sortable: false do |o|
    o.offerwall_channel.blank? ? '--' : link_to("#{o.offerwall_channel.name}-#{o.offerwall_channel.platform}", [:cpanel, o.offerwall_channel])
  end
  column :price
  column :points
  column('at', :created_at)
  
  actions
end


end
