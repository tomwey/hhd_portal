ActiveAdmin.register SignRule do
  
  # menu priority: 4, label: '口令规则'
  menu parent: 'hb_events', priority: 3, label: '口令规则'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :user_id, :answer, :answer_from_tip
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
    f.input :uid, as: :select, label: '所属用户', collection: User.includes(:wechat_profile).where(verified: true).order('id desc').map { |u| ["[#{u.uid}] #{u.format_nickname}", u.uid] }, prompt: '-- 选择所有者 --', input_html: { style: 'width: 50%;' }
    f.input :answer, hint: '如果需要多个口令，可以用英文逗号分隔'
    f.input :answer_from_tip
  end
  actions
end

end
