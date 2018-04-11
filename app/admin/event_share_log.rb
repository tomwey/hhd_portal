ActiveAdmin.register EventShareLog do

  #menu priority: 25, label: '活动分享记录'
  
  # menu parent: 'events', priority: 5
  menu false

  index do
    selectable_column
    column('ID', :id)
    column '用户', sortable: false do |log|
      link_to log.user.try(:uid), [:cpanel, log.user]
    end
    column '活动', sortable: false do |log|
      link_to log.event.try(:title), [:cpanel, log.event]
    end
    column :ip, sortable: false
    column :location, sortable: false
    column :created_at
  
    actions
  end


end
