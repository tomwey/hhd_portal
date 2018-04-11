ActiveAdmin.register UserPosterRedbag do
  
  menu parent: 'hb_events', priority: 8, label: '海报红包'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :user_id, :redbag_id, :share_poster_id

index do
  selectable_column
  column('ID', :uniq_id)
  column '海报图片', sortable: false do |o|
    o.share_poster_image.blank? ? '' : image_tag(o.share_poster_image, size: '180x350')
  end
  column '红包', sortable: false do |o|
    o.redbag_id.blank? ? '' : link_to(o.redbag.title, [:cpanel, o.redbag])
  end
  column '分享者', sortable: false do |o|
    o.user_id.blank? ? '' : link_to(o.user.format_nickname, [:cpanel, o.user])
  end
  
  actions
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :user_id, as: :select, label: '分享者', collection: User.where(verified: true).map { |o| [o.format_nickname, o.id] }
    f.input :redbag_id, as: :select, label: '红包', collection: Redbag.opened.event.order('id desc').map { |o| [o.title, o.id] }
    f.input :share_poster_id, as: :select, label: '海报', collection: SharePoster.order('id desc').map { |o| [o.title, o.id] }
  end
  actions
end

end
