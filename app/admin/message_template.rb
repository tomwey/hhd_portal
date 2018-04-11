ActiveAdmin.register MessageTemplate do

menu parent: 'wx_msg', priority: 1, label: '消息模板管理'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :tpl_id, :title, :body, :body_demo, :opened

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :tpl_id, as: :string, required: true
    f.input :title
    f.input :body, as: :text
    f.input :body_demo, as: :text
    f.input :opened
  end
  actions
  
end


end
