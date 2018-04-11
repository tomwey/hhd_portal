ActiveAdmin.register EventViewLog do

#menu priority: 6, label: '活动浏览记录'

# menu parent: 'events', priority: 4
menu false

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |log|
    log.user_id
  end
  column '活动', sortable: false do |log|
    log.event.try(:title)
  end
  column :ip, sortable: false
  column :location, sortable: false
  column :created_at
  
  actions
end


end
