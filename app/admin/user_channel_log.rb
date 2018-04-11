ActiveAdmin.register UserChannelLog do

menu parent: 'users', priority: 4, label: '用户来源记录'

index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |log|
    if log.user
      link_to log.user.try(:format_nickname), [:cpanel, log.user]
    else
      '--'
    end
  end
  column '来源渠道', sortable: false do |log|
    log.user_channel.try(:name)
  end
  column('at', :created_at)
  actions
end

end
