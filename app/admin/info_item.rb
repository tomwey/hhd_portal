ActiveAdmin.register InfoItem do
  
  menu parent: 'merchants', label: '广告内容', priority: 9
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :title, :image, :body

filter :uniq_id, label: 'ID'
filter :title, label: '标题'
filter :created_at, label: '创建时间'
filter :updated_at, label: '更新时间'

index do
  selectable_column
  column '所属商家', sortable: false do |o|
    link_to o.merchant.name, [:cpanel, o.merchant]
  end
  column :uniq_id, sortable: false
  column :title, sortable: false
  column :image, sortable: false do |o|
    o.image.blank? ? '' : image_tag(o.image.url(:small))
  end
  column 'at', :created_at
  
  actions
end

# before_create do |o|
#   o.merchant = current_admin_user.merchant
# end

show do
  div do
    raw("<div class=\"info-item-body\">#{info_item.body}</div>")
  end
end

# form html: { multipart: true } do |f|
#   f.semantic_errors
#
#   f.inputs '基本信息' do
#     f.input :title, placeholder: '输入标题'
#     f.input :image, hint: '图片格式为：jpg,jpeg,gif,png'
#     f.input :body, as: :text, input_html: { class: 'redactor' },
#       placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
#   end
#   actions
# end

form html: { multipart: true } do |f|
  f.semantic_errors
  
  f.inputs '基本信息' do
    f.input :title, placeholder: '输入标题'
    f.input :image, hint: '图片格式为：jpg,jpeg,gif,png'
    f.input :body, as: :text, input_html: { class: 'redactor' }, 
      placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
  end
  actions
end

end
