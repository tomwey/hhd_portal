ActiveAdmin.register Notification do
  menu parent: 'system', label: '通知'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :content, :is_prod, :merchant_id, :badge, :_type, :link, to_users: []
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :title, label: '标题', placeholder: '通知标题，例如：红包提醒'
    f.input :content, label: '内容', placeholder: '通知内容，例如：收到了一个来自惠互动官方红包'
    f.input :is_prod, as: :boolean, label: '是否是产品环境'
  end
  f.inputs '可选信息' do
    f.input :merchant_id, as: :select, label: '所属商家', collection: Merchant.where(opened: true).where('auth_type > 0').map { |m| [m.name, m.id] }, prompt: '-- 选择所属商家 --'
    f.input :to_users, as: :select, label: '通知接收人', multiple: true, placeholder: '选择接收者', collection: User.where(verified: true).map { |u| [u.format_nickname, u.id]  }, prompt: '-- 选择接收人 --', input_html: { style: 'width: 50%; height: 200px;' }
    
    f.input :badge, label: '应用图标气泡数字', placeholder:'默认值为1'
    f.input :_type, as: :select, label: '通知处理类型', collection: [['不处理', 0], ['打开一个网页', 1], ['跳转到具体红包',2], ['跳转到具体的优惠券',3]]
    f.input :link, label: '通知处理对象', placeholder: '可为空，也可以是URL地址或红包广告ID或优惠券ID；对应上面的通知处理类型', hint: '该字段的值对应上面的通知处理类型，如果为0，可不填；如果为1，值为一个URL地址；如果为2，值为某个红包广告的ID；如果为3,值为某个优惠券的ID'
  end
  actions
end

end
