ActiveAdmin.register SharePoster do
  
  menu parent: 'hb_events', priority: 5, label: '分享海报'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :image, :body_image, :qrcode_pos, :qrcode_other_configs,
:qrcode_text, :text_pos, :text_other_configs
#

index do
  selectable_column
  column('ID', :uniq_id)
  column :image, sortable: false do |o|
    image_tag o.image.url(:small)
  end
  column :title, sortable: false
  column 'at', :created_at
  actions
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :title, placeholder: '简单介绍这个海报广告'
    f.input :image, hint: '图片格式为：jpg,png,jpeg,gif'
    f.input :body_image, label: '内容详情图片', hint: '图片格式为：jpg,png,jpeg,gif'
  end
  
  f.inputs '二维码配置' do
    f.input :qrcode_pos, as: :select, label: '二维码位置', collection: SharePoster.qrcode_pos_data,
      prompt: '-- 选择二维码位置 --', input_html: { style: 'width: 240px;' }
    f.input :qrcode_other_configs, label: '二维码其它配置'
  end
  
  f.inputs '水印文字配置' do
    f.input :qrcode_text, label: '水印文字', hint: '如果不填，默认会动态生成，例如：识别二维码抢50元红包'
    f.input :text_pos, as: :select, label: '水印文字位置', collection: SharePoster.qrcode_pos_data,
      prompt: '-- 选择水印文字位置 --', input_html: { style: 'width: 240px;' }
    f.input :text_other_configs, label: '水印文字其它配置'
  end
  
  actions
end

end
