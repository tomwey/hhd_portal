ActiveAdmin.register Recharge do
  
  menu parent: 'merchants', label: '商家充值', priority: 3
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :merchant_id, :s_money

actions :all, except: [:show, :edit, :update, :destroy]

index do
  selectable_column
  column('流水号', :uniq_id)
  column '商家', sortable: false do |o|
    link_to o.merchant.name, [:cpanel, o.merchant]
  end
  column '充值金额' do |model, opts|
    "#{model.money / 100.0}元"
  end
  column('到账时间', :payed_at)
  
  column '充值时间' do |o|
    o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
  end
  actions
  
  div :class => "panel" do
    h3 "充值总金额: #{Recharge.where.not(payed_at: nil).sum(:money) / 100.0}元"
  end
  
end

before_create do |o|
  o.payed_at = Time.zone.now
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :s_money, as: :number, label: '充值金额', placeholder: '单位为元'
    f.input :merchant_id, as: :select, label: '商家', 
      collection: Merchant.where(opened: true).order('id desc').map { |o| [o.name, o.id] },
      prompt: '-- 选择商家 --'
  end
  actions
end

end
