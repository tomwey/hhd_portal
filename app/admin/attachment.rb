ActiveAdmin.register Attachment do

menu parent: 'system', priority: 60, label: '附件'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :data, :title
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column('ID', :uniq_id)
  column('附件说明', :title, sortable: false)
  column '附件所属', sortable: false do |a|
    a.attachmentable_type
  end
  column '附件所有人', sortable: false do |a|
    a.ownerable.try(:format_nickname) || a.ownerable.try(:email)
  end
  column '文件名', sortable: false do |a|
    link_to a.data_file_name, a.data.url
  end
  column 'at' do |a|
    a.created_at
  end
  
  actions

end

before_create do |a|
  a.ownerable = current_admin
end

before_update do |a|
  a.ownerable = current_admin
end

form html: { multipart: true } do |f|
  f.semantic_errors
  
  f.inputs '附件信息' do
    f.input :title, label: '附件说明'
    f.input :data
  end
  
  actions
end

end
