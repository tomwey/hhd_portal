ActiveAdmin.register RedbagViewLog do

  menu parent: 'hb', priority: 21
  
  index do
    selectable_column
    column('ID', :id)
    column '用户', sortable: false do |log|
      if log.user
        link_to log.user.try(:format_nickname), cpanel_user_path(log.user)
      else
        ''
      end
    end
    column '红包主题', sortable: false do |log|
      link_to log.redbag.try(:title), [:cpanel, log.redbag]
    end
    column :ip, sortable: false
    column :location, sortable: false
    column :created_at
  
    actions
  end


end
