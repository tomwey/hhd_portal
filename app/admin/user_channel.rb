ActiveAdmin.register UserChannel do

menu parent: 'users', priority: 3, label: '用户来源'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :address, :mobile

index do
  selectable_column
  column('ID', :uniq_id)
  column :name, sortable: false
  column :mobile, sortable: false
  column '渠道二维码', sortable: false do |ch|
    if ch.qrcode_ticket.blank?
      '生成二维码失败'
    else
      image_tag "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{ch.qrcode_ticket}", size: '60x60'
    end
  end
  actions
end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :name
    f.input :address
    f.input :mobile
  end
  actions
end

end
