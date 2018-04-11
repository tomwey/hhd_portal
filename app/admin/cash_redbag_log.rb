ActiveAdmin.register CashRedbagLog do

menu parent: 'hb', priority: 21

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
  column '用户', sortable: false do |o|
    link_to o.user.try(:format_nickname), [:cpanel, o.user]
  end
  column '所属红包', sortable: false do |o|
    link_to o.redbag.title, [:cpanel, o.redbag]
  end
  column :money
  column('发出时间', :sent_at)
  column '发送失败原因', sortable: false do |o|
    o.sent_error
  end
  
  column :created_at
  
  actions defaults: false do |o|
    item "查看", [:cpanel, o]
    if o.sent_at.blank?
      item "再次发红包", open_cpanel_cash_redbag_log_path(o), method: :put, data: { confirm: '您确定吗？' }
    end
  end
  
end

batch_action :open do |ids|
  batch_action_collection.find(ids).each do |e|
    e.send!
  end
  redirect_to collection_path, alert: "已发送"
end
member_action :open, method: :put do
  resource.send!
  redirect_to collection_path, notice: '已发送'
end


end
