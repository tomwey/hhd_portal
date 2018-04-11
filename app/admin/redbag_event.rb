ActiveAdmin.register RedbagEvent do

# menu parent: 'hb', priority: 2
menu parent: 'hb_events', priority: 1, label: '红包广告内容'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :uid, :title, :image, :body
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
  column :image, sortable: false do |e|
    image_tag e.image.url(:small)
  end
  column :title, sortable: false
  column '所有者', sortable: false do |event|
    link_to event.ownerable.try(:format_nickname) || event.ownerable.try(:email), [:cpanel, event.ownerable]
  end
  column :created_at
  
  actions
  
end

show do 
  render 'redbag_event_body', { event: redbag_event }
end

form html: { multipart: true } do |f|
  f.semantic_errors
  
  f.inputs '基本信息' do
    # if f.object.new_record?
    #   f.input :uid, label: '所属用户', required: true
    # end
    if f.object.new_record?
      f.input :uid, as: :select, label: '所有者ID', collection: User.includes(:wechat_profile).where(verified: true).order('id desc').map { |u| ["[#{u.uid}] #{u.format_nickname}", u.uid] }, prompt: '-- 选择所有者 --', required: true, input_html: { style: 'width: 50%;' }
    end
    f.input :title, placeholder: '输入标题'
    f.input :image, hint: '图片格式为：jpg,jpeg,gif,png'
    f.input :body, as: :text, input_html: { class: 'redactor' }, 
      placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
  end
  actions
end

end
