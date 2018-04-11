ActiveAdmin.register PayLog do
  menu parent: 'merchants', label: '交易明细', priority: 6
  
  actions :index
  
  filter :uniq_id
  filter :title
  filter :created_at
  
  index do
    selectable_column
    column('流水号', :uniq_id)
    column '所属商家', sortable: false do |o|
      link_to o.merchant.name, [:cpanel, o.merchant]
    end
    column '描述', :title, sortable: false
    column '金额' do |model, opts|
      "#{model.money / 100.0}元"
    end
    
    column 'at' do |o|
      o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
    end
    actions
  
  end

end
