ActiveAdmin.register LuckyDrawPrizeLog do

  menu parent: 'cj', label: '抽奖记录', priority: 2
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |log|
    link_to log.user.try(:format_nickname), [:cpanel, log.user]
  end
  column '抽奖主题', sortable: false do |log|
    link_to log.lucky_draw.try(:title), [:cpanel, log.lucky_draw]
  end
  column '中奖信息', sortable: false do |log|
    log.prize.name
  end
  column('at', :created_at) 

  actions
end


end
