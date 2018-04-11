ActiveAdmin.register RedbagShareLog do

  menu parent: 'hb', priority: 22

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |log|
    link_to log.user.try(:format_nickname), [:cpanel, log.user]
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
