ActiveAdmin.register Checkin do

  menu parent: 'hb', priority: 21
  
  index do
    selectable_column
    column('ID', :id)
    column '用户', sortable: false do |log|
      link_to log.user.try(:format_nickname), [:cpanel, log.user]
    end
    column :money
    # column :ip, sortable: false
    # column :location, sortable: false
    column('签到时间', :created_at)
  
    actions
  end


end
