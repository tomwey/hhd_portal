ActiveAdmin.register Like do

# menu priority: 9, label: '点赞'
menu false

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |like|
    link_to like.user.try(:uid), [:cpanel, like.user]
  end
  column '点赞对象', sortable: false do |like|
    like.likeable.try(:title) || like.likeable_type
  end
  column :ip, sortable: false
  column :location, sortable: false
  column :created_at
  
  actions
end


end
