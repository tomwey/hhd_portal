ActiveAdmin.register Charge do

menu parent: 'money', priority: 1, label: '充值'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#

scope :payed, default: true
scope :all

index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |o|
    link_to o.user.try(:format_nickname), [:cpanel, o.user]
  end
  column :money
  column('到账时间', :payed_at)
  
  column '充值时间' do |o|
    o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
  end
  actions
  
  div :class => "panel" do
    h3 "充值总金额: #{Charge.payed.sum(:money).to_f}元"
  end
  
end


end
