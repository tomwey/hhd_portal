ActiveAdmin.register Withdraw do

menu parent: 'money', priority: 2, label: '提现'

index do
  selectable_column
  column('ID', :id)
  column :oid
  column '用户', sortable: false do |o|
    link_to o.user.try(:format_nickname), [:cpanel, o.user]
  end
  column :account_no, sortable: false
  column :account_name, sortable: false
  column :money
  column :fee
  column('确认支付时间', :payed_at)
  
  column '申请提现时间' do |o|
    o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
  end
  
  actions defaults: false do |o|
    item "查看", [:cpanel, o]
    if current_admin.super_admin? && o.payed_at.blank?
      item "确认提现", confirm_pay_cpanel_withdraw_path(o), method: :put
    end
  end
  
  div :class => "panel" do
    h3 "提现总金额: #{Withdraw.sum(:money) - Withdraw.sum(:fee)}元"
  end
end

# 确认提现
batch_action :confirm_pay do |ids|
  batch_action_collection.find(ids).each do |e|
    e.confirm_pay!
  end
  redirect_to collection_path, alert: "已确认"
end
member_action :confirm_pay, method: :put do
  flag = resource.confirm_pay!
  if flag
    msg = '已提现'
  else
    msg = '提现失败'
  end
  redirect_to collection_path, notice: '已确认'
end


end
