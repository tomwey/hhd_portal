ActiveAdmin.register UserPay do
  
  menu parent: 'money', priority: 6, label: '余额抵扣记录'
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

scope :payed, default: true
scope :all

index do
  selectable_column
  column('ID', :uniq_id)
  column '用户', sortable: false do |us|
    link_to us.user.format_nickname, [:cpanel, us.user]
  end
  column '商家', sortable: false do |us|
    us.merchant_id.blank? ? '' : link_to(us.merchant.name, [:cpanel, us.merchant])
  end
  column '抵扣金额', :money
  column '支付时间', :payed_at
  column 'at', :created_at
  actions
end



end
